CREATE TRIGGER audit_logs_block_truncate
BEFORE TRUNCATE ON audit_logs
FOR EACH STATEMENT
EXECUTE FUNCTION audit_logs_append_only();
