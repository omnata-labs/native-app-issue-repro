-- This is the setup script that runs while installing a Snowflake Native App in a consumer account.
-- To write this script, you can familiarize yourself with some of the following concepts:
-- Application Roles
-- Versioned Schemas
-- UDFs/Procs
-- Extension Code
-- Refer to https://docs.snowflake.com/en/developer-guide/native-apps/creating-setup-script for a detailed understanding of this file.

create or alter versioned schema UI;

CREATE STREAMLIT if not exists UI."Administration"
  FROM '/streamlit-custom-component'
  MAIN_FILE = '/streamlit_app.py';

-- The rest of this script is left blank for purposes of your learning and exploration.
