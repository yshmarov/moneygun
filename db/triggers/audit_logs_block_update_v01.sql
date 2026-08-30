CREATE TRIGGER audit_logs_block_update
BEFORE UPDATE ON audit_logs
FOR EACH ROW
EXECUTE FUNCTION audit_logs_append_only();
