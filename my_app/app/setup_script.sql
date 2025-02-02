declare
    account_supports_hybrid boolean;
    table_action varchar;
begin
create application role if not exists APP_CONSUMER;

create schema if not exists DATA;

grant usage on schema DATA 
to application role APP_CONSUMER;

execute immediate from './setup_utilities.sql';
CALL SETUP_UTILITIES.HYBRID_TABLES_SUPPORTED() INTO account_supports_hybrid;

CALL SETUP_UTILITIES.DEPLOYMENT_ACTION(:account_supports_hybrid,current_database(),'DATA','MY_COOL_TABLE') into table_action;
if (table_action='base_to_hybrid') then
  execute immediate from './tables/MY_COOL_TABLE/base_to_hybrid.sql';
elseif (table_action='hybrid') then
  execute immediate from './tables/MY_COOL_TABLE/hybrid.sql';
elseif (table_action='base') then
  execute immediate from './tables/MY_COOL_TABLE/base.sql';
end if;
execute immediate from './tables/MY_COOL_TABLE/post.sql';

end;