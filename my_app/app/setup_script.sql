-- This is the setup script that runs while installing a Snowflake Native App in a consumer account.
-- To write this script, you can familiarize yourself with some of the following concepts:
-- Application Roles
-- Versioned Schemas
-- UDFs/Procs
-- Extension Code
-- Refer to https://docs.snowflake.com/en/developer-guide/native-apps/creating-setup-script for a detailed understanding of this file.
create application role if not exists NATIVE_APP_ROLE;
create or alter versioned schema UI;
create schema if not exists DATA;
grant usage on schema DATA to application role NATIVE_APP_ROLE;

CREATE STREAMLIT if not exists UI.TEST
  FROM '/streamlit'
  MAIN_FILE = '/streamlit_app.py'
;

-- The rest of this script is left blank for purposes of your learning and exploration.
grant usage on schema UI to application role NATIVE_APP_ROLE;
grant usage on streamlit UI.TEST to application role NATIVE_APP_ROLE;

create or alter versioned schema API;
grant usage on schema API to application role NATIVE_APP_ROLE;
create or replace procedure API.RUN_SQL(SQL_TEXT varchar)
    returns array
    language python
    RUNTIME_VERSION = '3.11'
    PACKAGES = ('snowflake-telemetry-python','snowflake-snowpark-python')
    HANDLER = 'run'
    COMMENT = $$
    Runs some SQL
    $$
    execute as owner
    as
    $$
from snowflake.snowpark import Session
def run(session: Session, sql_text: str):
  return [row.as_dict() for row in session.sql(sql_text).collect()]
$$;

grant usage on procedure API.RUN_SQL(varchar) to application role NATIVE_APP_ROLE;


create or replace procedure API.LIST_GOOGLE_SPREADSHEETS(OAUTH_SECRET_NAME varchar)
    returns array
    language python
    RUNTIME_VERSION = '3.11'
    ARTIFACT_REPOSITORY = snowflake.snowpark.pypi_shared_repository
    PACKAGES = ('snowflake-telemetry-python','snowflake-snowpark-python','google-api-python-client','google-auth','google-api-core','google-auth-oauthlib')
    HANDLER = 'run'
    COMMENT = $$
    Runs some SQL
    $$
    execute as owner
    as
    $$
import _snowflake
from snowflake.snowpark import Session
import googleapiclient
from google.oauth2.credentials import Credentials

def run(session: Session, oauth_secret_name:str):
  credentials = Credentials(token=_snowflake.get_oauth_access_token(oauth_secret_name))
  drive_service = googleapiclient.discovery.build('drive', 'v3', credentials=credentials, cache_discovery=False)
  fields = []
  page_token = None
  shared_with_me = True
  search_all_drives = True
  shared_with_me_clause = "sharedWithMe and " if shared_with_me else ""
  corpora = "allDrives" if search_all_drives else "user"
  while True:
      response = drive_service.files().list(q=f"{shared_with_me_clause}mimeType='application/vnd.google-apps.spreadsheet'",
                                            pageToken=page_token,
                                            supportsAllDrives=search_all_drives,
                                            includeItemsFromAllDrives=search_all_drives,
                                            corpora=corpora).execute() # pylint: disable=no-member
      for file in response.get('files', []):
          fields.append(
              FormOption(value=file['id'],
                  label=file['name'])
          )
      page_token = response.get('nextPageToken')
      if not page_token:
          break
  return sorted(fields, key=lambda d: d['label'])
$$;

grant usage on procedure API.LIST_GOOGLE_SPREADSHEETS(varchar) to application role NATIVE_APP_ROLE;

