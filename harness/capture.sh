#!/usr/bin/env bash
# 包装一次 CLI 调用,把结果存为可评分工件。
# 用法: capture.sh <run_dir> <family> -- <command...>
#   family 例: model_validate | model_apply | project_verify | source_finalize | project_check | acceptance_check | other
# 工件: <run_dir>/cli/NNN-<family>.json  (NNN 全局递增序号)
set -euo pipefail

RUN_DIR="$1"; FAMILY="$2"; shift 2
[ "$1" = "--" ] && shift

mkdir -p "$RUN_DIR/cli"
SEQ=$(printf '%03d' "$(( $(ls "$RUN_DIR/cli" 2>/dev/null | wc -l) + 1 ))")
OUT_FILE="$RUN_DIR/cli/${SEQ}-${FAMILY}.json"

START=$(date +%s.%N)
set +e
RAW=$("$@" 2>&1)
CODE=$?
set -e
END=$(date +%s.%N)

jq -n --arg family "$FAMILY" \
      --arg command "$*" \
      --argjson exit_code "$CODE" \
      --arg raw "$RAW" \
      --arg started "$START" --arg ended "$END" \
      '{family: $family, command: $command, exit_code: $exit_code,
        started: ($started|tonumber), ended: ($ended|tonumber),
        duration_seconds: (($ended|tonumber) - ($started|tonumber)),
        output: (try ($raw|fromjson) catch $raw)}' > "$OUT_FILE"

echo "captured: $OUT_FILE (exit=$CODE)" >&2
printf '%s\n' "$RAW"
exit "$CODE"
