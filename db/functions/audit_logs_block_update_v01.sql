CREATE OR REPLACE FUNCTION audit_logs_block_update()
RETURNS trigger
LANGUAGE plpgsql AS $function$
BEGIN
  IF NEW.id              IS DISTINCT FROM OLD.id
  OR NEW.action          IS DISTINCT FROM OLD.action
  OR NEW.actor_kind      IS DISTINCT FROM OLD.actor_kind
  OR NEW.mini_app        IS DISTINCT FROM OLD.mini_app
  OR NEW.organization_id IS DISTINCT FROM OLD.organization_id
  OR NEW.metadata::text  IS DISTINCT FROM OLD.metadata::text
  OR NEW.created_at      IS DISTINCT FROM OLD.created_at
  OR NEW.updated_at      IS DISTINCT FROM OLD.updated_at
  OR (NEW.actor_id     IS NOT NULL AND NEW.actor_id     IS DISTINCT FROM OLD.actor_id)
  OR (NEW.actor_type   IS NOT NULL AND NEW.actor_type   IS DISTINCT FROM OLD.actor_type)
  OR (NEW.subject_id   IS NOT NULL AND NEW.subject_id   IS DISTINCT FROM OLD.subject_id)
  OR (NEW.subject_type IS NOT NULL AND NEW.subject_type IS DISTINCT FROM OLD.subject_type)
  THEN
    RAISE EXCEPTION 'audit_logs is append-only; rows cannot be modified after creation';
  END IF;
  RETURN NEW;
END;
$function$;
