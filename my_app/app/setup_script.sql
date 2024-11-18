-- This is the setup script that runs while installing a Snowflake Native App in a consumer account.
-- To write this script, you can familiarize yourself with some of the following concepts:
-- Application Roles
-- Versioned Schemas
-- UDFs/Procs
-- Extension Code
-- Refer to https://docs.snowflake.com/en/developer-guide/native-apps/creating-setup-script for a detailed understanding of this file.

create application role if not exists APP_CONSUMER;

CREATE OR ALTER VERSIONED SCHEMA CORE;

create or replace procedure CORE.TO_PANDAS_BATCHES_TEST()
returns int
language python
RUNTIME_VERSION = '3.10'
PACKAGES = ('pycparser','annotated-types','Jinja2','cloudpickle','pytz','PyJWT','snowflake-snowpark-python','asn1crypto','platformdirs','cryptography','humanize','PGPy','numpy','six','PyYAML','jinja2','dictdiffer','pydantic','pandas','sortedcontainers','certifi','tomlkit','urllib3','pyarrow','bcrypt','PyNaCl','tenacity','requests','setuptools','wheel','MarkupSafe','filelock','pyOpenSSL','cffi','idna','charset-normalizer','packaging','pyasn1')
HANDLER = 'run'
COMMENT = $$
Checks that to_pandas_batches works in a native app
$$
execute as owner
as
$$
from logging import getLogger
logger = getLogger(__name__)

def run(session):
  batches = session.sql("""select seq4() from table(generator(rowcount=>100000))""").to_pandas_batches()
  result = 0
  for batch in batches:
    logger.info(batch)
    result += len(batch)
  return result
$$
;

grant usage on schema CORE 
to application role APP_CONSUMER;

grant usage on procedure CORE.TO_PANDAS_BATCHES_TEST()
to application role APP_CONSUMER;