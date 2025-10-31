-- This is the setup script that runs while installing a Snowflake Native App in a consumer account.
-- To write this script, you can familiarize yourself with some of the following concepts:
-- Application Roles
-- Versioned Schemas
-- UDFs/Procs
-- Extension Code
-- Refer to https://docs.snowflake.com/en/developer-guide/native-apps/creating-setup-script for a detailed understanding of this file.

create application role if not exists FUNCTION_CALLER;

CREATE OR ALTER VERSIONED SCHEMA UDFS;

CREATE OR REPLACE FUNCTION UDFS.HELLO_WORLD()
RETURNS STRING
  LANGUAGE PYTHON
  RUNTIME_VERSION = '3.12'
  HANDLER = 'run'
  AS
  $$
def run():
  return 'Hello, World!'
$$;
grant USAGE on schema UDFS to application role FUNCTION_CALLER;

grant USAGE on function UDFS.HELLO_WORLD() to application role FUNCTION_CALLER;

CREATE SCHEMA IF NOT EXISTS DATA;
GRANT USAGE ON SCHEMA DATA TO APPLICATION ROLE FUNCTION_CALLER;

CREATE OR REPLACE SECRET DATA.MY_SECRET TYPE = GENERIC_STRING SECRET_STRING = 'Password123';
grant usage on secret DATA.MY_SECRET to application role FUNCTION_CALLER;

CREATE OR REPLACE NETWORK RULE DATA.MY_NETWORK_RULE TYPE = HOST_PORT MODE = EGRESS VALUE_LIST = ('myapi.com');
grant usage on network rule DATA.MY_NETWORK_RULE to application role FUNCTION_CALLER;

-- this proc binds an external access integration to the HELLO_WORLD UDTF
create or replace procedure UDFS.BIND_INTEGRATION(EAI_NAME varchar)
   returns object
   language javascript
   COMMENT = $$
   Binds an external access integration to the HELLO_WORLD UDTF.
   $$
   execute as owner
as
$$
try{
  var sqlText = `alter function UDFS.HELLO_WORLD()
                set EXTERNAL_ACCESS_INTEGRATIONS = (${EAI_NAME}),
                    SECRETS = ('MY_SECRET' = DATA.MY_SECRET)`
    var appsResults = snowflake.createStatement( {
        sqlText:sqlText,
        binds:[]
    } ).execute();
    return {
        "success": true,
        "data": null
    }
}
catch(e){
   return {
      "success": false,
      "error": `BIND_INTEGRATION: ${String(e)}`
   }
}
$$
;

grant usage on procedure UDFS.BIND_INTEGRATION(VARCHAR) to application role FUNCTION_CALLER;

create or replace procedure UDFS.REVOKE_SCHEMA_ACCESS()
   returns object
   language javascript
   COMMENT = $$
   Revokes access to the internal schema
   $$
   execute as owner
as
$$
try{
  var sqlText = `revoke usage on schema DATA from application role FUNCTION_CALLER;`
    var appsResults = snowflake.createStatement( {
        sqlText:sqlText,
        binds:[]
    } ).execute();
    return {
        "success": true,
        "data": null
    }
}
catch(e){
   return {
      "success": false,
      "error": `REVOKE_SCHEMA_ACCESS: ${String(e)}`
   }
}
$$
;

grant usage on procedure UDFS.REVOKE_SCHEMA_ACCESS() to application role FUNCTION_CALLER;