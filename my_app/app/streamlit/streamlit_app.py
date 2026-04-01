import streamlit as st
from snowflake.snowpark.context import get_active_session

st.title(f"Example streamlit app.")

st.write(f"Streamlit version: ")
st.write(st.__version__)

session = get_active_session()

# Example of using the session to run a SQL query and display data
sql_text = st.text_area(label="SQL", key="sql_text")
if sql_text:
    try:
        result = session.sql(sql_text, []).collect()
        st.write(result)
    except Exception as exception:
        st.error(exception)

