create hybrid table if not exists DATA.MY_COOL_TABLE_MIGRATE(
    ID varchar PRIMARY KEY,
    SOME_VALUE varchar
)
as (
    select ID,SOME_VALUE from DATA.APP_SETTINGS
)
alter table DATA.MY_COOL_TABLE_MIGRATE swap with DATA.MY_COOL_TABLE;
drop table DATA.MY_COOL_TABLE_MIGRATE;
