declare
    account_supports_hybrid boolean;
    table_action string;
begin

create application role if not exists APP_CONSUMER;

create schema if not exists DATA;

grant usage on schema DATA 
to application role APP_CONSUMER;

execute immediate from './setup_utilities.sql';
CALL SETUP_UTILITIES.HYBRID_TABLES_SUPPORTED() INTO account_supports_hybrid;

CALL SETUP_UTILITIES.DEPLOYMENT_ACTION(:account_supports_hybrid,current_database(),'DATA','MY_COOL_TABLE') into table_action;
execute immediate from './tables/MY_COOL_TABLE.sql' using (deployment_action=>:table_action);

end;