-- This is the setup script that runs while installing a Snowflake Native App in a consumer account.
-- To write this script, you can familiarize yourself with some of the following concepts:
-- Application Roles
-- Versioned Schemas
-- UDFs/Procs
-- Extension Code
-- Refer to https://docs.snowflake.com/en/developer-guide/native-apps/creating-setup-script for a detailed understanding of this file.
create application role if not exists NATIVE_APP_ROLE;
create or alter versioned schema UI;

CREATE STREAMLIT if not exists UI.TEST
  FROM '/streamlit'
  MAIN_FILE = '/streamlit_app.py';

-- The rest of this script is left blank for purposes of your learning and exploration.
grant usage on schema UI to application role NATIVE_APP_ROLE;
grant usage on streamlit UI.TEST to application role NATIVE_APP_ROLE;