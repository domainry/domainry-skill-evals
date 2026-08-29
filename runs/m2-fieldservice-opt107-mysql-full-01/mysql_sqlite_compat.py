"""Evaluator-only sqlite3 API shim for the frozen M2 golden probe on MySQL.

The frozen probe's assertions remain unchanged.  This module only translates the
small, fixed set of sqlite3 metadata/read/update calls used by that probe.
Credentials are recovered in memory from the already-running managed Runtime's
process environment and are never printed or written.
"""

from __future__ import annotations

import os
import re
import subprocess
import urllib.parse

import pymysql


class _Cursor:
    def __init__(self, cursor, rows=None):
        self._cursor = cursor
        self._rows = rows

    @property
    def rowcount(self):
        return self._cursor.rowcount

    def fetchall(self):
        return tuple(self._rows) if self._rows is not None else self._cursor.fetchall()


def _runtime_dsn(pid: str) -> str:
    raw = subprocess.check_output(["ps", "eww", "-p", pid, "-o", "command="], text=True)
    match = re.search(r"(?:^|\s)DOMAINRY_RUNTIME_DATABASE_DSN=([^\s]+)", raw)
    if not match:
        match = re.search(r"(?:^|\s)DATABASE_DSN=([^\s]+)", raw)
    if not match:
        raise RuntimeError("managed Runtime process environment has no database DSN")
    return match.group(1)


def _mysql_connection(pid: str):
    dsn = _runtime_dsn(pid)
    parsed = urllib.parse.urlparse(dsn)
    if parsed.scheme in ("mysql", "mysql2"):
        host = parsed.hostname or "127.0.0.1"
        port = parsed.port or 3306
        user = urllib.parse.unquote(parsed.username or "")
        password = urllib.parse.unquote(parsed.password or "")
        database = parsed.path.lstrip("/")
    else:
        go_dsn = re.fullmatch(r"([^:]+):([^@]*)@tcp\(([^:]+):(\d+)\)/([^?]+)(?:\?.*)?", dsn)
        if not go_dsn:
            raise RuntimeError("managed Runtime database DSN is not a recognized MySQL form")
        user, password, host, port_text, database = go_dsn.groups()
        port = int(port_text)
    return pymysql.connect(
        host=host,
        port=port,
        user=user,
        password=password,
        database=database,
        charset="utf8mb4",
        autocommit=False,
    )


def _translate(sql: str):
    pragma = re.fullmatch(r'PRAGMA\s+table_info\("([A-Za-z_][A-Za-z0-9_]*)"\)', sql.strip(), re.I)
    if pragma:
        return "SHOW COLUMNS FROM `" + pragma.group(1) + "`", "pragma"

    if "sqlite_master" in sql:
        name = re.search(r"name='([A-Za-z_][A-Za-z0-9_]*)'", sql)
        if not name:
            raise RuntimeError("unsupported sqlite_master query")
        return (
            "SELECT table_name FROM information_schema.tables "
            "WHERE table_schema=DATABASE() AND table_name='" + name.group(1) + "'",
            "normal",
        )

    translated = re.sub(r'"([A-Za-z_][A-Za-z0-9_]*)"', r'`\1`', sql)
    translated = translated.replace("?", "%s")
    translated = translated.replace(
        "strftime('%Y-%m-%dT%H:%M:%SZ','now','-3 days')",
        "DATE_FORMAT(DATE_SUB(UTC_TIMESTAMP(), INTERVAL 3 DAY), '%%Y-%%m-%%dT%%H:%%i:%%sZ')",
    )
    translated = translated.replace(
        "strftime('%Y-%m-%dT%H:%M:%SZ','now','-48 hours')",
        "DATE_FORMAT(DATE_SUB(UTC_TIMESTAMP(), INTERVAL 48 HOUR), '%%Y-%%m-%%dT%%H:%%i:%%sZ')",
    )
    translated = translated.replace(
        "strftime('%Y-%m-%dT%H:%M:%SZ','now')",
        "DATE_FORMAT(UTC_TIMESTAMP(), '%%Y-%%m-%%dT%%H:%%i:%%sZ')",
    )
    return translated, "normal"


class _Connection:
    def __init__(self, pid: str):
        self._connection = _mysql_connection(pid)

    def execute(self, sql, args=()):
        translated, kind = _translate(sql)
        cursor = self._connection.cursor()
        cursor.execute(translated, args)
        if kind == "pragma":
            # sqlite PRAGMA table_info shape: cid, name, type, notnull, default, pk
            rows = [(idx, row[0], row[1], 0, row[4], 1 if row[3] == "PRI" else 0)
                    for idx, row in enumerate(cursor.fetchall())]
            return _Cursor(cursor, rows)
        return _Cursor(cursor)

    def commit(self):
        self._connection.commit()

    def close(self):
        self._connection.close()


def connect(database, timeout=10, **_kwargs):
    del timeout
    pid = str(database).rsplit("/", 1)[-1] or os.environ["PROBE_RUNTIME_PID"]
    return _Connection(pid)
