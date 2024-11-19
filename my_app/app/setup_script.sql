-- This is the setup script that runs while installing a Snowflake Native App in a consumer account.
-- To write this script, you can familiarize yourself with some of the following concepts:
-- Application Roles
-- Versioned Schemas
-- UDFs/Procs
-- Extension Code
-- Refer to https://docs.snowflake.com/en/developer-guide/native-apps/creating-setup-script for a detailed understanding of this file.

create application role if not exists APP_CONSUMER;

CREATE OR ALTER VERSIONED SCHEMA CORE;

CREATE OR REPLACE FUNCTION CORE.CUSTOM_SPANS_PYTHON_EXAMPLE() RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = 3.9
PACKAGES = ('snowflake-telemetry-python', 'opentelemetry-api')
HANDLER = 'custom_spans_function'
AS $$
from snowflake import telemetry
from opentelemetry import trace
import time
def custom_spans_function():
  tracer = trace.get_tracer("my.tracer")
  with tracer.start_as_current_span("my.span") as span:
    span.add_event("About to wait", {"seconds": 5})
    time.sleep(5)
    span.add_event("About to wait some more", {"seconds": 3})
    time.sleep(3)
    span.add_event("Done waiting")

  return "success"
$$;

grant usage on schema CORE 
to application role APP_CONSUMER;

grant usage on function CORE.CUSTOM_SPANS_PYTHON_EXAMPLE()
to application role APP_CONSUMER;