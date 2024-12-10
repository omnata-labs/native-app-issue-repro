--!jinja2
{%- if deployment_action == 'CREATE_OR_ALTER_BASE' -%}

create table if not exists DATA.MY_COOL_TABLE(
    ID varchar CONSTRAINT pkey PRIMARY KEY ENFORCED,
    SOME_VALUE varchar
)

{%- elif deployment_action == 'MIGRATE_TO_HYBRID' -%}

create hybrid table if not exists DATA.MY_COOL_TABLE_MIGRATE(
    ID varchar PRIMARY KEY,
    SOME_VALUE varchar
)
as (
    select ID,SOME_VALUE from DATA.APP_SETTINGS
)
alter table DATA.MY_COOL_TABLE_MIGRATE swap with DATA.MY_COOL_TABLE;
drop table DATA.MY_COOL_TABLE_MIGRATE;

{%- elif deployment_action == 'CREATE_OR_ALTER_HYBRID' -%}

create hybrid table if not exists DATA.MY_COOL_TABLE_MIGRATE(
    ID varchar PRIMARY KEY,
    SOME_VALUE varchar
)

{%- else -%}

select 1/0;

{%- endif -%}
