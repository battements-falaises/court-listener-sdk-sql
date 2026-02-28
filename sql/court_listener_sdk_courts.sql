ALTER TYPE court_listener_sdk_courts.court
  ADD ATTRIBUTE id TEXT,
  ADD ATTRIBUTE citation_string TEXT,
  ADD ATTRIBUTE date_created TIMESTAMP,
  ADD ATTRIBUTE date_modified TIMESTAMP,
  ADD ATTRIBUTE end_date DATE,
  ADD ATTRIBUTE full_name TEXT,
  ADD ATTRIBUTE in_use BOOLEAN,
  ADD ATTRIBUTE jurisdiction TEXT,
  ADD ATTRIBUTE "position" DOUBLE PRECISION,
  ADD ATTRIBUTE resource_uri TEXT,
  ADD ATTRIBUTE short_name TEXT,
  ADD ATTRIBUTE start_date DATE,
  ADD ATTRIBUTE url TEXT;

CREATE OR REPLACE FUNCTION court_listener_sdk_courts.make_court(
  id TEXT DEFAULT NULL,
  citation_string TEXT DEFAULT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  end_date DATE DEFAULT NULL,
  full_name TEXT DEFAULT NULL,
  in_use BOOLEAN DEFAULT NULL,
  jurisdiction TEXT DEFAULT NULL,
  "position" DOUBLE PRECISION DEFAULT NULL,
  resource_uri TEXT DEFAULT NULL,
  short_name TEXT DEFAULT NULL,
  start_date DATE DEFAULT NULL,
  url TEXT DEFAULT NULL
)
RETURNS court_listener_sdk_courts.court
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    id,
    citation_string,
    date_created,
    date_modified,
    end_date,
    full_name,
    in_use,
    jurisdiction,
    "position",
    resource_uri,
    short_name,
    start_date,
    url
  )::court_listener_sdk_courts.court;
$$;

CREATE OR REPLACE FUNCTION court_listener_sdk_courts._retrieve(
  id TEXT,
  fields TEXT DEFAULT NULL,
  format TEXT DEFAULT NULL,
  omit TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
STABLE
AS $$
  from court_listener_sdk._types import not_given

  response = GD["__court_listener_sdk_context__"].client.courts.with_raw_response.retrieve(
      id=id,
      fields=not_given if fields is None else fields,
      format=not_given if format is None else format,
      omit=not_given if omit is None else omit,
  )

  # We don't parse the JSON and let PL/Python perform data mapping because PL/Python errors for omitted
  # fields instead of defaulting them to NULL, but we want to be more lenient, which we handle in the
  # caller later.
  return response.text()
$$;

CREATE OR REPLACE FUNCTION court_listener_sdk_courts.retrieve(
  id TEXT,
  fields TEXT DEFAULT NULL,
  format TEXT DEFAULT NULL,
  omit TEXT DEFAULT NULL
)
RETURNS court_listener_sdk_courts.court
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM court_listener_sdk_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::court_listener_sdk_courts.court,
      court_listener_sdk_courts._retrieve(id, fields, format, omit)
    );
  END;
$$;

CREATE OR REPLACE FUNCTION court_listener_sdk_courts._list_first_page_py(
  id TEXT DEFAULT NULL,
  count TEXT DEFAULT NULL,
  cursor TEXT DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  date_modified_gte TIMESTAMP DEFAULT NULL,
  date_modified_lte TIMESTAMP DEFAULT NULL,
  fields TEXT DEFAULT NULL,
  format TEXT DEFAULT NULL,
  full_name TEXT DEFAULT NULL,
  full_name_startswith TEXT DEFAULT NULL,
  id_in TEXT DEFAULT NULL,
  jurisdiction TEXT DEFAULT NULL,
  omit TEXT DEFAULT NULL,
  order_by TEXT DEFAULT NULL,
  page BIGINT DEFAULT NULL
)
RETURNS court_listener_sdk_internal.page
LANGUAGE plpython3u
STABLE
AS $$
  from court_listener_sdk._types import not_given
  from pydantic import TypeAdapter
  from typing import Any

  page = GD["__court_listener_sdk_context__"].client.courts.list(
      id=not_given if id is None else id,
      count=not_given if count is None else count,
      cursor=not_given if cursor is None else cursor,
      date_modified=not_given if date_modified is None else date_modified,
      date_modified_gte=not_given if date_modified_gte is None else date_modified_gte,
      date_modified_lte=not_given if date_modified_lte is None else date_modified_lte,
      fields=not_given if fields is None else fields,
      format=not_given if format is None else format,
      full_name=not_given if full_name is None else full_name,
      full_name_startswith=not_given if full_name_startswith is None else full_name_startswith,
      id_in=not_given if id_in is None else id_in,
      jurisdiction=not_given if jurisdiction is None else jurisdiction,
      omit=not_given if omit is None else omit,
      order_by=not_given if order_by is None else order_by,
      page=not_given if page is None else page,
  )
  next_page_info = page.next_page_info()
  if next_page_info is None:
      next_request_options = None
  else:
      next_request_options = page._info_to_options(next_page_info).model_dump_json(
        exclude_unset=True,
        exclude={'post_parser'}
      )

  # We convert to JSON instead of letting PL/Python perform data mapping because PL/Python errors for
  # omitted fields instead of defaulting them to NULL, but we want to be more lenient, which we handle
  # in the calling function later.
  type_adapter = TypeAdapter(Any)
  return (
    type_adapter.dump_json(page._get_page_items(), exclude_unset=True).decode("utf-8"),
    next_request_options
  )
$$;

-- A simpler wrapper around `court_listener_sdk_courts._list_first_page` that ensures the global client is initialized.
CREATE OR REPLACE FUNCTION court_listener_sdk_courts._list_first_page(
  id TEXT DEFAULT NULL,
  count TEXT DEFAULT NULL,
  cursor TEXT DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  date_modified_gte TIMESTAMP DEFAULT NULL,
  date_modified_lte TIMESTAMP DEFAULT NULL,
  fields TEXT DEFAULT NULL,
  format TEXT DEFAULT NULL,
  full_name TEXT DEFAULT NULL,
  full_name_startswith TEXT DEFAULT NULL,
  id_in TEXT DEFAULT NULL,
  jurisdiction TEXT DEFAULT NULL,
  omit TEXT DEFAULT NULL,
  order_by TEXT DEFAULT NULL,
  page BIGINT DEFAULT NULL
)
RETURNS court_listener_sdk_internal.page
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM court_listener_sdk_internal.ensure_context();
    RETURN court_listener_sdk_courts._list_first_page_py(
      id,
      count,
      cursor,
      date_modified,
      date_modified_gte,
      date_modified_lte,
      fields,
      format,
      full_name,
      full_name_startswith,
      id_in,
      jurisdiction,
      omit,
      order_by,
      page
    );
  END;
$$;

CREATE OR REPLACE FUNCTION court_listener_sdk_courts._list_next_page(request_options JSONB)
RETURNS court_listener_sdk_internal.page
LANGUAGE plpython3u
STABLE
AS $$
  import json
  from court_listener_sdk.types import Court
  from court_listener_sdk.pagination import SyncCursorURLPage
  from court_listener_sdk._models import FinalRequestOptions
  from pydantic import TypeAdapter
  from typing import Any

  page = GD["__court_listener_sdk_context__"].client._request_api_list(
    model=Court,
    page=SyncCursorURLPage[Court],
    options=FinalRequestOptions.construct(**json.loads(request_options))
  )
  next_page_info = page.next_page_info()
  if next_page_info is None:
      next_request_options = None
  else:
      next_request_options = page._info_to_options(next_page_info).model_dump_json(
        exclude_unset=True,
        exclude={'post_parser'}
      )

  # We convert to JSON instead of letting PL/Python perform data mapping because PL/Python errors for
  # omitted fields instead of defaulting them to NULL, but we want to be more lenient, which we handle
  # in the calling function later.
  type_adapter = TypeAdapter(Any)
  return (
    type_adapter.dump_json(page._get_page_items(), exclude_unset=True).decode("utf-8"),
    next_request_options
  )
$$;

CREATE OR REPLACE FUNCTION court_listener_sdk_courts.list(
  id TEXT DEFAULT NULL,
  count TEXT DEFAULT NULL,
  cursor TEXT DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  date_modified_gte TIMESTAMP DEFAULT NULL,
  date_modified_lte TIMESTAMP DEFAULT NULL,
  fields TEXT DEFAULT NULL,
  format TEXT DEFAULT NULL,
  full_name TEXT DEFAULT NULL,
  full_name_startswith TEXT DEFAULT NULL,
  id_in TEXT DEFAULT NULL,
  jurisdiction TEXT DEFAULT NULL,
  omit TEXT DEFAULT NULL,
  order_by TEXT DEFAULT NULL,
  page BIGINT DEFAULT NULL
)
RETURNS SETOF court_listener_sdk_courts.court
LANGUAGE SQL
STABLE
AS $$
  WITH RECURSIVE paginated AS (
    SELECT page.*
    FROM court_listener_sdk_courts._list_first_page(
      id,
      count,
      cursor,
      date_modified,
      date_modified_gte,
      date_modified_lte,
      fields,
      format,
      full_name,
      full_name_startswith,
      id_in,
      jurisdiction,
      omit,
      order_by,
      page
    ) AS page

    UNION ALL

    SELECT page.*
    FROM paginated
    CROSS JOIN court_listener_sdk_courts._list_next_page(paginated.next_request_options) AS page
    WHERE paginated.next_request_options IS NOT NULL
  )
  SELECT (jsonb_populate_recordset(NULL::court_listener_sdk_courts.court, data)).* FROM paginated;
$$;