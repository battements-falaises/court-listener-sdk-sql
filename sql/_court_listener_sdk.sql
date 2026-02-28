-- A file that declares all schemas and types upfront so that their definitions don't
-- have to be topologically sorted in other files. It also creates some internal utility functions.

CREATE SCHEMA IF NOT EXISTS court_listener_sdk_internal;
REVOKE ALL ON SCHEMA court_listener_sdk_internal FROM PUBLIC;

CREATE OR REPLACE FUNCTION court_listener_sdk_internal.ensure_empty_type(
  p_schema TEXT,
  p_type TEXT
)
RETURNS void
LANGUAGE plpgsql
AS $$
  DECLARE
    attr RECORD;
  BEGIN
    -- Create an empty type if it doesn't exist from a previous extension version.
    IF NOT EXISTS (
      SELECT 1
      FROM pg_type t
      JOIN pg_namespace n ON n.oid = t.typnamespace
      WHERE t.typname = p_type
        AND n.nspname = p_schema
    ) THEN
      EXECUTE format(
        'CREATE TYPE %I.%I AS ();',
        p_schema,
        p_type
      );
      -- Already empty, nothing to drop.
      RETURN;
    END IF;

    -- Drop all existing attributes from the previous extension version so we can readd them.
    FOR attr IN
      SELECT a.attname
      FROM pg_attribute a
      JOIN pg_type t ON t.typrelid = a.attrelid
      JOIN pg_namespace n ON n.oid = t.typnamespace
      WHERE t.typname = p_type
        AND n.nspname = p_schema
        AND a.attnum > 0
        AND NOT a.attisdropped
      ORDER BY a.attnum DESC
    LOOP
      EXECUTE format(
        'ALTER TYPE %I.%I DROP ATTRIBUTE %I;',
        p_schema,
        p_type,
        attr.attname
      );
    END LOOP;
  END;
$$;

CREATE OR REPLACE FUNCTION court_listener_sdk_internal.ensure_context()
RETURNS void
LANGUAGE plpython3u
AS $$
  from types import SimpleNamespace
  from court_listener_sdk import CourtListener

  if "__court_listener_sdk_context__" in GD:
      # The context was already created.
      return

  client_options = {}
  try:
      value = plpy.execute("SELECT current_setting('court_listener_sdk.base_url') AS value")[0]['value']
      client_options["base_url"] = value
  except Exception:
      # This configuration parameter was not set, but it's optional so ignore the exception.
      pass
  try:
      value = plpy.execute("SELECT current_setting('court_listener_sdk.api_key') AS value")[0]['value']
      client_options["api_key"] = value
  except Exception:
      # This configuration parameter was not set, but it's optional so ignore the exception.
      pass
  try:
      value = plpy.execute("SELECT current_setting('court_listener_sdk.username') AS value")[0]['value']
      client_options["username"] = value
  except Exception:
      # This configuration parameter was not set, but it's optional so ignore the exception.
      pass
  try:
      value = plpy.execute("SELECT current_setting('court_listener_sdk.password') AS value")[0]['value']
      client_options["password"] = value
  except Exception:
      # This configuration parameter was not set, but it's optional so ignore the exception.
      pass

  def strip_none(value):
      if isinstance(value, dict):
          return {
              k: strip_none(v)
              for k, v in value.items()
              if v is not None
          }
      elif isinstance(value, list):
          return [strip_none(v) for v in value]
      else:
          return value

  GD["__court_listener_sdk_context__"] = SimpleNamespace(
      client=CourtListener(**client_options),
      strip_none=strip_none,
  )
$$;

CREATE TYPE court_listener_sdk_internal.page AS (
  data JSONB,
  next_request_options JSONB
);

CREATE SCHEMA IF NOT EXISTS court_listener_sdk_courts;

CREATE TYPE court_listener_sdk_courts.court AS ();

CREATE SCHEMA IF NOT EXISTS court_listener_sdk_dockets;

CREATE TYPE court_listener_sdk_dockets.docket AS ();

CREATE SCHEMA IF NOT EXISTS court_listener_sdk_clusters;

CREATE TYPE court_listener_sdk_clusters.cluster AS ();
CREATE TYPE court_listener_sdk_clusters.cluster_citation AS ();

CREATE SCHEMA IF NOT EXISTS court_listener_sdk_opinions;

CREATE TYPE court_listener_sdk_opinions.opinion AS ();