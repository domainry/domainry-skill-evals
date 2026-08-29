# Invalid setup — excluded

This attempted control copied the checkpoint with `git clone`, which omitted ignored `.domainry` materialization receipts. The first and only `project source prepare` therefore failed before source mutation with `project file batch context requires current materialization receipt`.

The process was stopped and this run is excluded from every timing and quality comparison. The valid replacement is `m2-fieldservice-43c91fec9277-mysql-implement-control-02`, created from a complete file-level checkpoint copy with a new Agent session and a new MySQL database.
