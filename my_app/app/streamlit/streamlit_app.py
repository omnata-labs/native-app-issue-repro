import streamlit as st
from snowflake.snowpark.context import get_active_session
import snowflake
from snowflake.permissions import request_application_configuration_value,get_application_configurations, request_application_specification_review
# https://app.snowflake.com/org/account_name/#/streamlit-apps/DB.SCHEMA.APP_NAME?streamlit-first_key=one&streamlit-second_key=two

st.title(f"Example streamlit app.")

st.write(f"Streamlit version: ")
st.write(st.__version__)

session = get_active_session()
st.write(st.user)
# Example of using the session to run a SQL query and display data
sql_text = st.text_area(label="SQL", key="sql_text")
if sql_text:
    try:
        result = session.sql(sql_text, []).collect()
        st.write(result)
    except Exception as exception:
        st.error(exception)
