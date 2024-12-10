create schema if not exists SETUP_UTILITIES;

-- This file contains procs/functions that are solely used by the setup script
create or replace procedure SETUP_UTILITIES.HYBRID_TABLES_SUPPORTED()
RETURNS boolean
LANGUAGE javascript
COMMENT = $$
This proc is called by the plugin runtime during installation/upgrade, to check whether or not hybrid tables are supported.
$$
AS
$$
    try {
        const sql = `create or replace hybrid table TEST_HYBRID_TABLE(
          id NUMBER PRIMARY KEY AUTOINCREMENT START 1 INCREMENT 1
        );`;
        var statement = snowflake.createStatement({
        sqlText: sql,
        binds:[]
        });
        statement.execute();
        return true;
    } catch(err) {
        if (err.message.indexOf('Unsupported feature') > -1){
            return false;
        }
        throw err;
    }
$$;

create or replace procedure SETUP_UTILITIES.DEPLOYMENT_ACTION(
                                            account_supports_hybrid boolean,
                                            database_name varchar, 
                                            schema_name varchar,
                                            table_name varchar)
returns varchar
language sql
comment = $$
This proc returns one of three string values:
- 'MIGRATE_TO_HYBRID' if the account supports hybrid tables but currently the table exists as a regular table
- 'CREATE_OR_ALTER_HYBRID' if the account supports hybrid and the table does not exist as a regular table
- 'CREATE_OR_ALTER_REGULAR' if the account does not support hybrid tables
Note: This ignores the scenario where the hybrid table was created and now the account doesn't support hybrid tables, as this should not be possible.
$$
as
DECLARE
  hybrid_table_count INTEGER;
  base_table_count INTEGER;
  table_action varchar;
  INVALID_TABLE_STATE EXCEPTION (-20002, 'Invalid table state, please contact support@omnata.com');
  tables_query CURSOR FOR 
    select 
       coalesce(COUNT_IF(TABLE_TYPE='HYBRID TABLE'),0) as HYBRID_TABLE_COUNT,
       coalesce(COUNT_IF(TABLE_TYPE='BASE TABLE'),0) as BASE_TABLE_COUNT
    from INFORMATION_SCHEMA.TABLES
    where TABLE_CATALOG=?
    and TABLE_SCHEMA=?
    and TABLE_NAME=?;
BEGIN
  if (not(:account_supports_hybrid)) then
    -- if hybrid tables are not supported, fall back to regular
    return 'CREATE_OR_ALTER_BASE';
  else
    OPEN tables_query USING (:database_name, :schema_name,:table_name);
    FETCH tables_query INTO :hybrid_table_count,:base_table_count;
    if (:base_table_count>0) then
      return 'MIGRATE_TO_HYBRID';
    else
      return 'CREATE_OR_ALTER_HYBRID';
    end if;
  end if;
  RAISE INVALID_TABLE_STATE;
END;
