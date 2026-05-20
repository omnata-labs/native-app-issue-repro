import streamlit as st
from snowflake.snowpark.context import get_active_session
import snowflake
from snowflake.permissions import request_application_configuration_value,get_application_configurations, request_application_specification_review
# https://app.snowflake.com/org/account_name/#/streamlit-apps/DB.SCHEMA.APP_NAME?streamlit-first_key=one&streamlit-second_key=two

if 'review_app_spec' in st.query_params:
    app_specs = st.query_params.get('review_app_spec').split(',')
    request_application_specification_review(app_specs)
    st.write(f"Requested application specification review for {', '.join(app_specs)}")
    st.stop()

st.title(f"Example streamlit app.")

st.write(f"Streamlit version: ")
st.write(st.__version__)

session = get_active_session()

current_org = session.sql("SELECT CURRENT_ORGANIZATION_NAME()").collect()[0][0]
current_account = session.sql("SELECT CURRENT_ACCOUNT_name()").collect()[0][0]

st.write(f"Current organization: {current_org}")
st.write(f"Current account: {current_account}")

# Example of using the session to run a SQL query and display data
sql_text = st.text_area(label="SQL", key="sql_text")
if sql_text:
    try:
        result = session.sql(sql_text, []).collect()
        st.write(result)
    except Exception as exception:
        st.error(exception)


if st.button("Get application configurations"):
    st.write(get_application_configurations())

if st.button("Get application configuration value for GOOGLE_SHEETS_OAUTH_CONFIG"):
    config_value = request_application_configuration_value(config_names=['GOOGLE_SHEETS_OAUTH_CONFIG'])
    st.write(config_value)

if st.button("Request application specification review"):
    request_application_specification_review(["GOOGLE_SHEETS_SI_SPEC","GOOGLE_SHEETS_EAI_SPEC_2"])
    st.write("Requested application specification review for GOOGLE_SHEETS_SI_SPEC and GOOGLE_SHEETS_EAI_SPEC_2")