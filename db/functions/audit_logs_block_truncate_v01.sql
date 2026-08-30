CREATE OR REPLACE FUNCTION audit_logs_block_truncate()
RETURNS trigger
LANGUAGE plpgsql AS $function$
BEGIN
  RAISE EXCEPTION 'audit_logs is append-only; TRUNCATE is not permitted';
  RETURN NULL;
END;
$function$;
