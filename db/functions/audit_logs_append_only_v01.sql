CREATE OR REPLACE FUNCTION audit_logs_append_only()
RETURNS trigger
LANGUAGE plpgsql AS $function$
BEGIN
  RAISE EXCEPTION 'audit_logs is append-only';
END;
$function$;
