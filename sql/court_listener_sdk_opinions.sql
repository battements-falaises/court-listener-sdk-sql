ALTER TYPE court_listener_sdk_opinions.opinion
  ADD ATTRIBUTE id BIGINT,
  ADD ATTRIBUTE author TEXT,
  ADD ATTRIBUTE author_str TEXT,
  ADD ATTRIBUTE cluster TEXT,
  ADD ATTRIBUTE date_created TIMESTAMP,
  ADD ATTRIBUTE date_modified TIMESTAMP,
  ADD ATTRIBUTE download_url TEXT,
  ADD ATTRIBUTE extracted_by_ocr BOOLEAN,
  ADD ATTRIBUTE html TEXT,
  ADD ATTRIBUTE html_anon_2020 TEXT,
  ADD ATTRIBUTE html_columbia TEXT,
  ADD ATTRIBUTE html_lawbox TEXT,
  ADD ATTRIBUTE html_with_citations TEXT,
  ADD ATTRIBUTE joined_by TEXT[],
  ADD ATTRIBUTE local_path TEXT,
  ADD ATTRIBUTE opinions_cited TEXT[],
  ADD ATTRIBUTE ordering_key DOUBLE PRECISION,
  ADD ATTRIBUTE per_curiam BOOLEAN,
  ADD ATTRIBUTE plain_text TEXT,
  ADD ATTRIBUTE resource_uri TEXT,
  ADD ATTRIBUTE sha1 TEXT,
  ADD ATTRIBUTE type TEXT,
  ADD ATTRIBUTE xml_harvard TEXT;

CREATE OR REPLACE FUNCTION court_listener_sdk_opinions.make_opinion(
  id BIGINT DEFAULT NULL,
  author TEXT DEFAULT NULL,
  author_str TEXT DEFAULT NULL,
  cluster TEXT DEFAULT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  download_url TEXT DEFAULT NULL,
  extracted_by_ocr BOOLEAN DEFAULT NULL,
  html TEXT DEFAULT NULL,
  html_anon_2020 TEXT DEFAULT NULL,
  html_columbia TEXT DEFAULT NULL,
  html_lawbox TEXT DEFAULT NULL,
  html_with_citations TEXT DEFAULT NULL,
  joined_by TEXT[] DEFAULT NULL,
  local_path TEXT DEFAULT NULL,
  opinions_cited TEXT[] DEFAULT NULL,
  ordering_key DOUBLE PRECISION DEFAULT NULL,
  per_curiam BOOLEAN DEFAULT NULL,
  plain_text TEXT DEFAULT NULL,
  resource_uri TEXT DEFAULT NULL,
  sha1 TEXT DEFAULT NULL,
  type TEXT DEFAULT NULL,
  xml_harvard TEXT DEFAULT NULL
)
RETURNS court_listener_sdk_opinions.opinion
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    id,
    author,
    author_str,
    cluster,
    date_created,
    date_modified,
    download_url,
    extracted_by_ocr,
    html,
    html_anon_2020,
    html_columbia,
    html_lawbox,
    html_with_citations,
    joined_by,
    local_path,
    opinions_cited,
    ordering_key,
    per_curiam,
    plain_text,
    resource_uri,
    sha1,
    type,
    xml_harvard
  )::court_listener_sdk_opinions.opinion;
$$;

CREATE OR REPLACE FUNCTION court_listener_sdk_opinions._retrieve(
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

  response = GD["__court_listener_sdk_context__"].client.opinions.with_raw_response.retrieve(
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

CREATE OR REPLACE FUNCTION court_listener_sdk_opinions.retrieve(
  id BIGINT,
  fields TEXT DEFAULT NULL,
  format TEXT DEFAULT NULL,
  omit TEXT DEFAULT NULL
)
RETURNS court_listener_sdk_opinions.opinion
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM court_listener_sdk_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::court_listener_sdk_opinions.opinion,
      court_listener_sdk_opinions._retrieve(id, fields, format, omit)
    );
  END;
$$;

CREATE OR REPLACE FUNCTION court_listener_sdk_opinions._list_first_page_py(
  id BIGINT DEFAULT NULL,
  cited_opinion BIGINT DEFAULT NULL,
  cluster BIGINT DEFAULT NULL,
  cluster_docket_court TEXT DEFAULT NULL,
  cluster_docket_docket_number TEXT DEFAULT NULL,
  count TEXT DEFAULT NULL,
  cursor TEXT DEFAULT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  date_created_gte TIMESTAMP DEFAULT NULL,
  date_created_lte TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  date_modified_gte TIMESTAMP DEFAULT NULL,
  date_modified_lte TIMESTAMP DEFAULT NULL,
  fields TEXT DEFAULT NULL,
  format TEXT DEFAULT NULL,
  id_gt BIGINT DEFAULT NULL,
  id_gte BIGINT DEFAULT NULL,
  id_lt BIGINT DEFAULT NULL,
  id_lte BIGINT DEFAULT NULL,
  id_range TEXT DEFAULT NULL,
  omit TEXT DEFAULT NULL,
  order_by TEXT DEFAULT NULL,
  page BIGINT DEFAULT NULL,
  type TEXT DEFAULT NULL
)
RETURNS court_listener_sdk_internal.page
LANGUAGE plpython3u
STABLE
AS $$
  from court_listener_sdk._types import not_given
  from pydantic import TypeAdapter
  from typing import Any

  page = GD["__court_listener_sdk_context__"].client.opinions.list(
      id=not_given if id is None else id,
      cited_opinion=not_given if cited_opinion is None else cited_opinion,
      cluster=not_given if cluster is None else cluster,
      cluster_docket_court=not_given if cluster_docket_court is None else cluster_docket_court,
      cluster_docket_docket_number=not_given if cluster_docket_docket_number is None else cluster_docket_docket_number,
      count=not_given if count is None else count,
      cursor=not_given if cursor is None else cursor,
      date_created=not_given if date_created is None else date_created,
      date_created_gte=not_given if date_created_gte is None else date_created_gte,
      date_created_lte=not_given if date_created_lte is None else date_created_lte,
      date_modified=not_given if date_modified is None else date_modified,
      date_modified_gte=not_given if date_modified_gte is None else date_modified_gte,
      date_modified_lte=not_given if date_modified_lte is None else date_modified_lte,
      fields=not_given if fields is None else fields,
      format=not_given if format is None else format,
      id_gt=not_given if id_gt is None else id_gt,
      id_gte=not_given if id_gte is None else id_gte,
      id_lt=not_given if id_lt is None else id_lt,
      id_lte=not_given if id_lte is None else id_lte,
      id_range=not_given if id_range is None else id_range,
      omit=not_given if omit is None else omit,
      order_by=not_given if order_by is None else order_by,
      page=not_given if page is None else page,
      type=not_given if type is None else type,
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

-- A simpler wrapper around `court_listener_sdk_opinions._list_first_page` that ensures the global client is initialized.
CREATE OR REPLACE FUNCTION court_listener_sdk_opinions._list_first_page(
  id BIGINT DEFAULT NULL,
  cited_opinion BIGINT DEFAULT NULL,
  cluster BIGINT DEFAULT NULL,
  cluster_docket_court TEXT DEFAULT NULL,
  cluster_docket_docket_number TEXT DEFAULT NULL,
  count TEXT DEFAULT NULL,
  cursor TEXT DEFAULT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  date_created_gte TIMESTAMP DEFAULT NULL,
  date_created_lte TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  date_modified_gte TIMESTAMP DEFAULT NULL,
  date_modified_lte TIMESTAMP DEFAULT NULL,
  fields TEXT DEFAULT NULL,
  format TEXT DEFAULT NULL,
  id_gt BIGINT DEFAULT NULL,
  id_gte BIGINT DEFAULT NULL,
  id_lt BIGINT DEFAULT NULL,
  id_lte BIGINT DEFAULT NULL,
  id_range TEXT DEFAULT NULL,
  omit TEXT DEFAULT NULL,
  order_by TEXT DEFAULT NULL,
  page BIGINT DEFAULT NULL,
  type TEXT DEFAULT NULL
)
RETURNS court_listener_sdk_internal.page
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM court_listener_sdk_internal.ensure_context();
    RETURN court_listener_sdk_opinions._list_first_page_py(
      id,
      cited_opinion,
      cluster,
      cluster_docket_court,
      cluster_docket_docket_number,
      count,
      cursor,
      date_created,
      date_created_gte,
      date_created_lte,
      date_modified,
      date_modified_gte,
      date_modified_lte,
      fields,
      format,
      id_gt,
      id_gte,
      id_lt,
      id_lte,
      id_range,
      omit,
      order_by,
      page,
      type
    );
  END;
$$;

CREATE OR REPLACE FUNCTION court_listener_sdk_opinions._list_next_page(request_options JSONB)
RETURNS court_listener_sdk_internal.page
LANGUAGE plpython3u
STABLE
AS $$
  import json
  from court_listener_sdk.types import Opinion
  from court_listener_sdk.pagination import SyncCursorURLPage
  from court_listener_sdk._models import FinalRequestOptions
  from pydantic import TypeAdapter
  from typing import Any

  page = GD["__court_listener_sdk_context__"].client._request_api_list(
    model=Opinion,
    page=SyncCursorURLPage[Opinion],
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

CREATE OR REPLACE FUNCTION court_listener_sdk_opinions.list(
  id BIGINT DEFAULT NULL,
  cited_opinion BIGINT DEFAULT NULL,
  cluster BIGINT DEFAULT NULL,
  cluster_docket_court TEXT DEFAULT NULL,
  cluster_docket_docket_number TEXT DEFAULT NULL,
  count TEXT DEFAULT NULL,
  cursor TEXT DEFAULT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  date_created_gte TIMESTAMP DEFAULT NULL,
  date_created_lte TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  date_modified_gte TIMESTAMP DEFAULT NULL,
  date_modified_lte TIMESTAMP DEFAULT NULL,
  fields TEXT DEFAULT NULL,
  format TEXT DEFAULT NULL,
  id_gt BIGINT DEFAULT NULL,
  id_gte BIGINT DEFAULT NULL,
  id_lt BIGINT DEFAULT NULL,
  id_lte BIGINT DEFAULT NULL,
  id_range TEXT DEFAULT NULL,
  omit TEXT DEFAULT NULL,
  order_by TEXT DEFAULT NULL,
  page BIGINT DEFAULT NULL,
  type TEXT DEFAULT NULL
)
RETURNS SETOF court_listener_sdk_opinions.opinion
LANGUAGE SQL
STABLE
AS $$
  WITH RECURSIVE paginated AS (
    SELECT page.*
    FROM court_listener_sdk_opinions._list_first_page(
      id,
      cited_opinion,
      cluster,
      cluster_docket_court,
      cluster_docket_docket_number,
      count,
      cursor,
      date_created,
      date_created_gte,
      date_created_lte,
      date_modified,
      date_modified_gte,
      date_modified_lte,
      fields,
      format,
      id_gt,
      id_gte,
      id_lt,
      id_lte,
      id_range,
      omit,
      order_by,
      page,
      type
    ) AS page

    UNION ALL

    SELECT page.*
    FROM paginated
    CROSS JOIN court_listener_sdk_opinions._list_next_page(paginated.next_request_options) AS page
    WHERE paginated.next_request_options IS NOT NULL
  )
  SELECT (jsonb_populate_recordset(NULL::court_listener_sdk_opinions.opinion, data)).* FROM paginated;
$$;