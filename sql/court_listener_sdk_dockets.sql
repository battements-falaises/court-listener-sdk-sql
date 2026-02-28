ALTER TYPE court_listener_sdk_dockets.docket
  ADD ATTRIBUTE id BIGINT,
  ADD ATTRIBUTE absolute_url TEXT,
  ADD ATTRIBUTE appeal_from TEXT,
  ADD ATTRIBUTE appeal_from_str TEXT,
  ADD ATTRIBUTE appellate_case_type_information TEXT,
  ADD ATTRIBUTE appellate_fee_status TEXT,
  ADD ATTRIBUTE assigned_to TEXT,
  ADD ATTRIBUTE assigned_to_str TEXT,
  ADD ATTRIBUTE audio_files TEXT[],
  ADD ATTRIBUTE bankruptcy_information JSONB,
  ADD ATTRIBUTE blocked BOOLEAN,
  ADD ATTRIBUTE case_name TEXT,
  ADD ATTRIBUTE case_name_full TEXT,
  ADD ATTRIBUTE case_name_short TEXT,
  ADD ATTRIBUTE cause TEXT,
  ADD ATTRIBUTE clusters TEXT[],
  ADD ATTRIBUTE court TEXT,
  ADD ATTRIBUTE court_id TEXT,
  ADD ATTRIBUTE date_argued DATE,
  ADD ATTRIBUTE date_blocked DATE,
  ADD ATTRIBUTE date_cert_denied DATE,
  ADD ATTRIBUTE date_cert_granted DATE,
  ADD ATTRIBUTE date_created TIMESTAMP,
  ADD ATTRIBUTE date_filed DATE,
  ADD ATTRIBUTE date_last_filing DATE,
  ADD ATTRIBUTE date_last_index TIMESTAMP,
  ADD ATTRIBUTE date_modified TIMESTAMP,
  ADD ATTRIBUTE date_reargued DATE,
  ADD ATTRIBUTE date_reargument_denied DATE,
  ADD ATTRIBUTE date_terminated DATE,
  ADD ATTRIBUTE docket_number TEXT,
  ADD ATTRIBUTE docket_number_core TEXT,
  ADD ATTRIBUTE filepath_ia TEXT,
  ADD ATTRIBUTE filepath_ia_json TEXT,
  ADD ATTRIBUTE ia_date_first_change TIMESTAMP,
  ADD ATTRIBUTE ia_needs_upload BOOLEAN,
  ADD ATTRIBUTE ia_upload_failure_count BIGINT,
  ADD ATTRIBUTE idb_data JSONB,
  ADD ATTRIBUTE jurisdiction_type TEXT,
  ADD ATTRIBUTE jury_demand TEXT,
  ADD ATTRIBUTE mdl_status TEXT,
  ADD ATTRIBUTE nature_of_suit TEXT,
  ADD ATTRIBUTE original_court_info JSONB,
  ADD ATTRIBUTE pacer_case_id TEXT,
  ADD ATTRIBUTE panel TEXT[],
  ADD ATTRIBUTE panel_str TEXT,
  ADD ATTRIBUTE referred_to TEXT,
  ADD ATTRIBUTE referred_to_str TEXT,
  ADD ATTRIBUTE resource_uri TEXT,
  ADD ATTRIBUTE slug TEXT,
  ADD ATTRIBUTE source BIGINT,
  ADD ATTRIBUTE tags TEXT[];

CREATE OR REPLACE FUNCTION court_listener_sdk_dockets.make_docket(
  id BIGINT DEFAULT NULL,
  absolute_url TEXT DEFAULT NULL,
  appeal_from TEXT DEFAULT NULL,
  appeal_from_str TEXT DEFAULT NULL,
  appellate_case_type_information TEXT DEFAULT NULL,
  appellate_fee_status TEXT DEFAULT NULL,
  assigned_to TEXT DEFAULT NULL,
  assigned_to_str TEXT DEFAULT NULL,
  audio_files TEXT[] DEFAULT NULL,
  bankruptcy_information JSONB DEFAULT NULL,
  blocked BOOLEAN DEFAULT NULL,
  case_name TEXT DEFAULT NULL,
  case_name_full TEXT DEFAULT NULL,
  case_name_short TEXT DEFAULT NULL,
  cause TEXT DEFAULT NULL,
  clusters TEXT[] DEFAULT NULL,
  court TEXT DEFAULT NULL,
  court_id TEXT DEFAULT NULL,
  date_argued DATE DEFAULT NULL,
  date_blocked DATE DEFAULT NULL,
  date_cert_denied DATE DEFAULT NULL,
  date_cert_granted DATE DEFAULT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  date_filed DATE DEFAULT NULL,
  date_last_filing DATE DEFAULT NULL,
  date_last_index TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  date_reargued DATE DEFAULT NULL,
  date_reargument_denied DATE DEFAULT NULL,
  date_terminated DATE DEFAULT NULL,
  docket_number TEXT DEFAULT NULL,
  docket_number_core TEXT DEFAULT NULL,
  filepath_ia TEXT DEFAULT NULL,
  filepath_ia_json TEXT DEFAULT NULL,
  ia_date_first_change TIMESTAMP DEFAULT NULL,
  ia_needs_upload BOOLEAN DEFAULT NULL,
  ia_upload_failure_count BIGINT DEFAULT NULL,
  idb_data JSONB DEFAULT NULL,
  jurisdiction_type TEXT DEFAULT NULL,
  jury_demand TEXT DEFAULT NULL,
  mdl_status TEXT DEFAULT NULL,
  nature_of_suit TEXT DEFAULT NULL,
  original_court_info JSONB DEFAULT NULL,
  pacer_case_id TEXT DEFAULT NULL,
  panel TEXT[] DEFAULT NULL,
  panel_str TEXT DEFAULT NULL,
  referred_to TEXT DEFAULT NULL,
  referred_to_str TEXT DEFAULT NULL,
  resource_uri TEXT DEFAULT NULL,
  slug TEXT DEFAULT NULL,
  source BIGINT DEFAULT NULL,
  tags TEXT[] DEFAULT NULL
)
RETURNS court_listener_sdk_dockets.docket
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    id,
    absolute_url,
    appeal_from,
    appeal_from_str,
    appellate_case_type_information,
    appellate_fee_status,
    assigned_to,
    assigned_to_str,
    audio_files,
    bankruptcy_information,
    blocked,
    case_name,
    case_name_full,
    case_name_short,
    cause,
    clusters,
    court,
    court_id,
    date_argued,
    date_blocked,
    date_cert_denied,
    date_cert_granted,
    date_created,
    date_filed,
    date_last_filing,
    date_last_index,
    date_modified,
    date_reargued,
    date_reargument_denied,
    date_terminated,
    docket_number,
    docket_number_core,
    filepath_ia,
    filepath_ia_json,
    ia_date_first_change,
    ia_needs_upload,
    ia_upload_failure_count,
    idb_data,
    jurisdiction_type,
    jury_demand,
    mdl_status,
    nature_of_suit,
    original_court_info,
    pacer_case_id,
    panel,
    panel_str,
    referred_to,
    referred_to_str,
    resource_uri,
    slug,
    source,
    tags
  )::court_listener_sdk_dockets.docket;
$$;

CREATE OR REPLACE FUNCTION court_listener_sdk_dockets._retrieve(
  id BIGINT,
  fields TEXT DEFAULT NULL,
  format TEXT DEFAULT NULL,
  omit TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpython3u
STABLE
AS $$
  from court_listener_sdk._types import not_given

  response = GD["__court_listener_sdk_context__"].client.dockets.with_raw_response.retrieve(
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

CREATE OR REPLACE FUNCTION court_listener_sdk_dockets.retrieve(
  id BIGINT,
  fields TEXT DEFAULT NULL,
  format TEXT DEFAULT NULL,
  omit TEXT DEFAULT NULL
)
RETURNS court_listener_sdk_dockets.docket
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM court_listener_sdk_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::court_listener_sdk_dockets.docket,
      court_listener_sdk_dockets._retrieve(id, fields, format, omit)
    );
  END;
$$;

CREATE OR REPLACE FUNCTION court_listener_sdk_dockets._list_first_page_py(
  id BIGINT DEFAULT NULL,
  blocked BOOLEAN DEFAULT NULL,
  case_name TEXT DEFAULT NULL,
  cause TEXT DEFAULT NULL,
  count TEXT DEFAULT NULL,
  court TEXT DEFAULT NULL,
  query_court_jurisdiction_1 TEXT DEFAULT NULL,
  query_court_jurisdiction_2 TEXT DEFAULT NULL,
  cursor TEXT DEFAULT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  date_created_gte TIMESTAMP DEFAULT NULL,
  date_created_lte TIMESTAMP DEFAULT NULL,
  date_filed DATE DEFAULT NULL,
  date_filed_gte DATE DEFAULT NULL,
  date_filed_lte DATE DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  date_modified_gte TIMESTAMP DEFAULT NULL,
  date_modified_lte TIMESTAMP DEFAULT NULL,
  date_terminated DATE DEFAULT NULL,
  date_terminated_gte DATE DEFAULT NULL,
  date_terminated_lte DATE DEFAULT NULL,
  docket_number TEXT DEFAULT NULL,
  fields TEXT DEFAULT NULL,
  format TEXT DEFAULT NULL,
  id_gt BIGINT DEFAULT NULL,
  id_gte BIGINT DEFAULT NULL,
  id_lt BIGINT DEFAULT NULL,
  id_lte BIGINT DEFAULT NULL,
  id_range TEXT DEFAULT NULL,
  nature_of_suit TEXT DEFAULT NULL,
  omit TEXT DEFAULT NULL,
  order_by TEXT DEFAULT NULL,
  page BIGINT DEFAULT NULL,
  source BIGINT DEFAULT NULL
)
RETURNS court_listener_sdk_internal.page
LANGUAGE plpython3u
STABLE
AS $$
  from court_listener_sdk._types import not_given
  from pydantic import TypeAdapter
  from typing import Any

  page = GD["__court_listener_sdk_context__"].client.dockets.list(
      id=not_given if id is None else id,
      blocked=not_given if blocked is None else blocked,
      case_name=not_given if case_name is None else case_name,
      cause=not_given if cause is None else cause,
      count=not_given if count is None else count,
      court=not_given if court is None else court,
      query_court_jurisdiction_1=not_given if query_court_jurisdiction_1 is None else query_court_jurisdiction_1,
      query_court_jurisdiction_2=not_given if query_court_jurisdiction_2 is None else query_court_jurisdiction_2,
      cursor=not_given if cursor is None else cursor,
      date_created=not_given if date_created is None else date_created,
      date_created_gte=not_given if date_created_gte is None else date_created_gte,
      date_created_lte=not_given if date_created_lte is None else date_created_lte,
      date_filed=not_given if date_filed is None else date_filed,
      date_filed_gte=not_given if date_filed_gte is None else date_filed_gte,
      date_filed_lte=not_given if date_filed_lte is None else date_filed_lte,
      date_modified=not_given if date_modified is None else date_modified,
      date_modified_gte=not_given if date_modified_gte is None else date_modified_gte,
      date_modified_lte=not_given if date_modified_lte is None else date_modified_lte,
      date_terminated=not_given if date_terminated is None else date_terminated,
      date_terminated_gte=not_given if date_terminated_gte is None else date_terminated_gte,
      date_terminated_lte=not_given if date_terminated_lte is None else date_terminated_lte,
      docket_number=not_given if docket_number is None else docket_number,
      fields=not_given if fields is None else fields,
      format=not_given if format is None else format,
      id_gt=not_given if id_gt is None else id_gt,
      id_gte=not_given if id_gte is None else id_gte,
      id_lt=not_given if id_lt is None else id_lt,
      id_lte=not_given if id_lte is None else id_lte,
      id_range=not_given if id_range is None else id_range,
      nature_of_suit=not_given if nature_of_suit is None else nature_of_suit,
      omit=not_given if omit is None else omit,
      order_by=not_given if order_by is None else order_by,
      page=not_given if page is None else page,
      source=not_given if source is None else source,
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

-- A simpler wrapper around `court_listener_sdk_dockets._list_first_page` that ensures the global client is initialized.
CREATE OR REPLACE FUNCTION court_listener_sdk_dockets._list_first_page(
  id BIGINT DEFAULT NULL,
  blocked BOOLEAN DEFAULT NULL,
  case_name TEXT DEFAULT NULL,
  cause TEXT DEFAULT NULL,
  count TEXT DEFAULT NULL,
  court TEXT DEFAULT NULL,
  query_court_jurisdiction_1 TEXT DEFAULT NULL,
  query_court_jurisdiction_2 TEXT DEFAULT NULL,
  cursor TEXT DEFAULT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  date_created_gte TIMESTAMP DEFAULT NULL,
  date_created_lte TIMESTAMP DEFAULT NULL,
  date_filed DATE DEFAULT NULL,
  date_filed_gte DATE DEFAULT NULL,
  date_filed_lte DATE DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  date_modified_gte TIMESTAMP DEFAULT NULL,
  date_modified_lte TIMESTAMP DEFAULT NULL,
  date_terminated DATE DEFAULT NULL,
  date_terminated_gte DATE DEFAULT NULL,
  date_terminated_lte DATE DEFAULT NULL,
  docket_number TEXT DEFAULT NULL,
  fields TEXT DEFAULT NULL,
  format TEXT DEFAULT NULL,
  id_gt BIGINT DEFAULT NULL,
  id_gte BIGINT DEFAULT NULL,
  id_lt BIGINT DEFAULT NULL,
  id_lte BIGINT DEFAULT NULL,
  id_range TEXT DEFAULT NULL,
  nature_of_suit TEXT DEFAULT NULL,
  omit TEXT DEFAULT NULL,
  order_by TEXT DEFAULT NULL,
  page BIGINT DEFAULT NULL,
  source BIGINT DEFAULT NULL
)
RETURNS court_listener_sdk_internal.page
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM court_listener_sdk_internal.ensure_context();
    RETURN court_listener_sdk_dockets._list_first_page_py(
      id,
      blocked,
      case_name,
      cause,
      count,
      court,
      query_court_jurisdiction_1,
      query_court_jurisdiction_2,
      cursor,
      date_created,
      date_created_gte,
      date_created_lte,
      date_filed,
      date_filed_gte,
      date_filed_lte,
      date_modified,
      date_modified_gte,
      date_modified_lte,
      date_terminated,
      date_terminated_gte,
      date_terminated_lte,
      docket_number,
      fields,
      format,
      id_gt,
      id_gte,
      id_lt,
      id_lte,
      id_range,
      nature_of_suit,
      omit,
      order_by,
      page,
      source
    );
  END;
$$;

CREATE OR REPLACE FUNCTION court_listener_sdk_dockets._list_next_page(request_options JSONB)
RETURNS court_listener_sdk_internal.page
LANGUAGE plpython3u
STABLE
AS $$
  import json
  from court_listener_sdk.types import Docket
  from court_listener_sdk.pagination import SyncCursorURLPage
  from court_listener_sdk._models import FinalRequestOptions
  from pydantic import TypeAdapter
  from typing import Any

  page = GD["__court_listener_sdk_context__"].client._request_api_list(
    model=Docket,
    page=SyncCursorURLPage[Docket],
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

CREATE OR REPLACE FUNCTION court_listener_sdk_dockets.list(
  id BIGINT DEFAULT NULL,
  blocked BOOLEAN DEFAULT NULL,
  case_name TEXT DEFAULT NULL,
  cause TEXT DEFAULT NULL,
  count TEXT DEFAULT NULL,
  court TEXT DEFAULT NULL,
  query_court_jurisdiction_1 TEXT DEFAULT NULL,
  query_court_jurisdiction_2 TEXT DEFAULT NULL,
  cursor TEXT DEFAULT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  date_created_gte TIMESTAMP DEFAULT NULL,
  date_created_lte TIMESTAMP DEFAULT NULL,
  date_filed DATE DEFAULT NULL,
  date_filed_gte DATE DEFAULT NULL,
  date_filed_lte DATE DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  date_modified_gte TIMESTAMP DEFAULT NULL,
  date_modified_lte TIMESTAMP DEFAULT NULL,
  date_terminated DATE DEFAULT NULL,
  date_terminated_gte DATE DEFAULT NULL,
  date_terminated_lte DATE DEFAULT NULL,
  docket_number TEXT DEFAULT NULL,
  fields TEXT DEFAULT NULL,
  format TEXT DEFAULT NULL,
  id_gt BIGINT DEFAULT NULL,
  id_gte BIGINT DEFAULT NULL,
  id_lt BIGINT DEFAULT NULL,
  id_lte BIGINT DEFAULT NULL,
  id_range TEXT DEFAULT NULL,
  nature_of_suit TEXT DEFAULT NULL,
  omit TEXT DEFAULT NULL,
  order_by TEXT DEFAULT NULL,
  page BIGINT DEFAULT NULL,
  source BIGINT DEFAULT NULL
)
RETURNS SETOF court_listener_sdk_dockets.docket
LANGUAGE SQL
STABLE
AS $$
  WITH RECURSIVE paginated AS (
    SELECT page.*
    FROM court_listener_sdk_dockets._list_first_page(
      id,
      blocked,
      case_name,
      cause,
      count,
      court,
      query_court_jurisdiction_1,
      query_court_jurisdiction_2,
      cursor,
      date_created,
      date_created_gte,
      date_created_lte,
      date_filed,
      date_filed_gte,
      date_filed_lte,
      date_modified,
      date_modified_gte,
      date_modified_lte,
      date_terminated,
      date_terminated_gte,
      date_terminated_lte,
      docket_number,
      fields,
      format,
      id_gt,
      id_gte,
      id_lt,
      id_lte,
      id_range,
      nature_of_suit,
      omit,
      order_by,
      page,
      source
    ) AS page

    UNION ALL

    SELECT page.*
    FROM paginated
    CROSS JOIN court_listener_sdk_dockets._list_next_page(paginated.next_request_options) AS page
    WHERE paginated.next_request_options IS NOT NULL
  )
  SELECT (jsonb_populate_recordset(NULL::court_listener_sdk_dockets.docket, data)).* FROM paginated;
$$;