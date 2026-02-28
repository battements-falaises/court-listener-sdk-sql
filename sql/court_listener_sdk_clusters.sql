ALTER TYPE court_listener_sdk_clusters.cluster
  ADD ATTRIBUTE id BIGINT,
  ADD ATTRIBUTE absolute_url TEXT,
  ADD ATTRIBUTE blocked BOOLEAN,
  ADD ATTRIBUTE case_name TEXT,
  ADD ATTRIBUTE case_name_full TEXT,
  ADD ATTRIBUTE case_name_short TEXT,
  ADD ATTRIBUTE citation_count BIGINT,
  ADD ATTRIBUTE citations court_listener_sdk_clusters.cluster_citation[],
  ADD ATTRIBUTE correction TEXT,
  ADD ATTRIBUTE cross_reference TEXT,
  ADD ATTRIBUTE date_blocked DATE,
  ADD ATTRIBUTE date_created TIMESTAMP,
  ADD ATTRIBUTE date_filed DATE,
  ADD ATTRIBUTE date_filed_is_approximate BOOLEAN,
  ADD ATTRIBUTE date_modified TIMESTAMP,
  ADD ATTRIBUTE disposition TEXT,
  ADD ATTRIBUTE docket TEXT,
  ADD ATTRIBUTE headnotes TEXT,
  ADD ATTRIBUTE history TEXT,
  ADD ATTRIBUTE judges TEXT,
  ADD ATTRIBUTE non_participating_judges TEXT[],
  ADD ATTRIBUTE other_dates TEXT,
  ADD ATTRIBUTE panel TEXT[],
  ADD ATTRIBUTE precedential_status TEXT,
  ADD ATTRIBUTE resource_uri TEXT,
  ADD ATTRIBUTE slug TEXT,
  ADD ATTRIBUTE source TEXT,
  ADD ATTRIBUTE sub_opinions TEXT[],
  ADD ATTRIBUTE summary TEXT,
  ADD ATTRIBUTE syllabus TEXT;

CREATE OR REPLACE FUNCTION court_listener_sdk_clusters.make_cluster(
  id BIGINT DEFAULT NULL,
  absolute_url TEXT DEFAULT NULL,
  blocked BOOLEAN DEFAULT NULL,
  case_name TEXT DEFAULT NULL,
  case_name_full TEXT DEFAULT NULL,
  case_name_short TEXT DEFAULT NULL,
  citation_count BIGINT DEFAULT NULL,
  citations court_listener_sdk_clusters.cluster_citation[] DEFAULT NULL,
  correction TEXT DEFAULT NULL,
  cross_reference TEXT DEFAULT NULL,
  date_blocked DATE DEFAULT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  date_filed DATE DEFAULT NULL,
  date_filed_is_approximate BOOLEAN DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  disposition TEXT DEFAULT NULL,
  docket TEXT DEFAULT NULL,
  headnotes TEXT DEFAULT NULL,
  history TEXT DEFAULT NULL,
  judges TEXT DEFAULT NULL,
  non_participating_judges TEXT[] DEFAULT NULL,
  other_dates TEXT DEFAULT NULL,
  panel TEXT[] DEFAULT NULL,
  precedential_status TEXT DEFAULT NULL,
  resource_uri TEXT DEFAULT NULL,
  slug TEXT DEFAULT NULL,
  source TEXT DEFAULT NULL,
  sub_opinions TEXT[] DEFAULT NULL,
  summary TEXT DEFAULT NULL,
  syllabus TEXT DEFAULT NULL
)
RETURNS court_listener_sdk_clusters.cluster
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    id,
    absolute_url,
    blocked,
    case_name,
    case_name_full,
    case_name_short,
    citation_count,
    citations,
    correction,
    cross_reference,
    date_blocked,
    date_created,
    date_filed,
    date_filed_is_approximate,
    date_modified,
    disposition,
    docket,
    headnotes,
    history,
    judges,
    non_participating_judges,
    other_dates,
    panel,
    precedential_status,
    resource_uri,
    slug,
    source,
    sub_opinions,
    summary,
    syllabus
  )::court_listener_sdk_clusters.cluster;
$$;

ALTER TYPE court_listener_sdk_clusters.cluster_citation
  ADD ATTRIBUTE page TEXT,
  ADD ATTRIBUTE reporter TEXT,
  ADD ATTRIBUTE type BIGINT,
  ADD ATTRIBUTE volume BIGINT;

CREATE OR REPLACE FUNCTION court_listener_sdk_clusters.make_cluster_citation(
  page TEXT DEFAULT NULL,
  reporter TEXT DEFAULT NULL,
  type BIGINT DEFAULT NULL,
  volume BIGINT DEFAULT NULL
)
RETURNS court_listener_sdk_clusters.cluster_citation
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT ROW(
    page, reporter, type, volume
  )::court_listener_sdk_clusters.cluster_citation;
$$;

CREATE OR REPLACE FUNCTION court_listener_sdk_clusters._retrieve(
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

  response = GD["__court_listener_sdk_context__"].client.clusters.with_raw_response.retrieve(
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

CREATE OR REPLACE FUNCTION court_listener_sdk_clusters.retrieve(
  id BIGINT,
  fields TEXT DEFAULT NULL,
  format TEXT DEFAULT NULL,
  omit TEXT DEFAULT NULL
)
RETURNS court_listener_sdk_clusters.cluster
LANGUAGE plpgsql
STABLE
AS $$
  BEGIN
    PERFORM court_listener_sdk_internal.ensure_context();
    RETURN jsonb_populate_record(
      NULL::court_listener_sdk_clusters.cluster,
      court_listener_sdk_clusters._retrieve(id, fields, format, omit)
    );
  END;
$$;

CREATE OR REPLACE FUNCTION court_listener_sdk_clusters._list_first_page_py(
  id BIGINT DEFAULT NULL,
  citation TEXT DEFAULT NULL,
  count TEXT DEFAULT NULL,
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
  docket BIGINT DEFAULT NULL,
  docket_court TEXT DEFAULT NULL,
  docket_docket_number TEXT DEFAULT NULL,
  fields TEXT DEFAULT NULL,
  format TEXT DEFAULT NULL,
  id_gt BIGINT DEFAULT NULL,
  id_gte BIGINT DEFAULT NULL,
  id_lt BIGINT DEFAULT NULL,
  id_lte BIGINT DEFAULT NULL,
  id_range TEXT DEFAULT NULL,
  judges TEXT DEFAULT NULL,
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

  page = GD["__court_listener_sdk_context__"].client.clusters.list(
      id=not_given if id is None else id,
      citation=not_given if citation is None else citation,
      count=not_given if count is None else count,
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
      docket=not_given if docket is None else docket,
      docket_court=not_given if docket_court is None else docket_court,
      docket_docket_number=not_given if docket_docket_number is None else docket_docket_number,
      fields=not_given if fields is None else fields,
      format=not_given if format is None else format,
      id_gt=not_given if id_gt is None else id_gt,
      id_gte=not_given if id_gte is None else id_gte,
      id_lt=not_given if id_lt is None else id_lt,
      id_lte=not_given if id_lte is None else id_lte,
      id_range=not_given if id_range is None else id_range,
      judges=not_given if judges is None else judges,
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

-- A simpler wrapper around `court_listener_sdk_clusters._list_first_page` that ensures the global client is initialized.
CREATE OR REPLACE FUNCTION court_listener_sdk_clusters._list_first_page(
  id BIGINT DEFAULT NULL,
  citation TEXT DEFAULT NULL,
  count TEXT DEFAULT NULL,
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
  docket BIGINT DEFAULT NULL,
  docket_court TEXT DEFAULT NULL,
  docket_docket_number TEXT DEFAULT NULL,
  fields TEXT DEFAULT NULL,
  format TEXT DEFAULT NULL,
  id_gt BIGINT DEFAULT NULL,
  id_gte BIGINT DEFAULT NULL,
  id_lt BIGINT DEFAULT NULL,
  id_lte BIGINT DEFAULT NULL,
  id_range TEXT DEFAULT NULL,
  judges TEXT DEFAULT NULL,
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
    RETURN court_listener_sdk_clusters._list_first_page_py(
      id,
      citation,
      count,
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
      docket,
      docket_court,
      docket_docket_number,
      fields,
      format,
      id_gt,
      id_gte,
      id_lt,
      id_lte,
      id_range,
      judges,
      omit,
      order_by,
      page
    );
  END;
$$;

CREATE OR REPLACE FUNCTION court_listener_sdk_clusters._list_next_page(request_options JSONB)
RETURNS court_listener_sdk_internal.page
LANGUAGE plpython3u
STABLE
AS $$
  import json
  from court_listener_sdk.types import Cluster
  from court_listener_sdk.pagination import SyncCursorURLPage
  from court_listener_sdk._models import FinalRequestOptions
  from pydantic import TypeAdapter
  from typing import Any

  page = GD["__court_listener_sdk_context__"].client._request_api_list(
    model=Cluster,
    page=SyncCursorURLPage[Cluster],
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

CREATE OR REPLACE FUNCTION court_listener_sdk_clusters.list(
  id BIGINT DEFAULT NULL,
  citation TEXT DEFAULT NULL,
  count TEXT DEFAULT NULL,
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
  docket BIGINT DEFAULT NULL,
  docket_court TEXT DEFAULT NULL,
  docket_docket_number TEXT DEFAULT NULL,
  fields TEXT DEFAULT NULL,
  format TEXT DEFAULT NULL,
  id_gt BIGINT DEFAULT NULL,
  id_gte BIGINT DEFAULT NULL,
  id_lt BIGINT DEFAULT NULL,
  id_lte BIGINT DEFAULT NULL,
  id_range TEXT DEFAULT NULL,
  judges TEXT DEFAULT NULL,
  omit TEXT DEFAULT NULL,
  order_by TEXT DEFAULT NULL,
  page BIGINT DEFAULT NULL
)
RETURNS SETOF court_listener_sdk_clusters.cluster
LANGUAGE SQL
STABLE
AS $$
  WITH RECURSIVE paginated AS (
    SELECT page.*
    FROM court_listener_sdk_clusters._list_first_page(
      id,
      citation,
      count,
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
      docket,
      docket_court,
      docket_docket_number,
      fields,
      format,
      id_gt,
      id_gte,
      id_lt,
      id_lte,
      id_range,
      judges,
      omit,
      order_by,
      page
    ) AS page

    UNION ALL

    SELECT page.*
    FROM paginated
    CROSS JOIN court_listener_sdk_clusters._list_next_page(paginated.next_request_options) AS page
    WHERE paginated.next_request_options IS NOT NULL
  )
  SELECT (jsonb_populate_recordset(NULL::court_listener_sdk_clusters.cluster, data)).* FROM paginated;
$$;