import streamlit as st
import streamlit.components.v1 as components
from ai.agents import RelationalDataSystem
import pandas as pd
import numpy as np

# Set page title and layout
st.set_page_config(page_title="DataSage", layout="wide")


if "query_response" not in st.session_state:
    st.session_state.query_response = "" 

if "df_response" not in st.session_state:
    st.session_state.df_response = None

if "query" not in st.session_state:
    st.session_state.query = ""

# Sidebar with logo and description
with st.sidebar:
    st.image("images/logo.png", width=150)  # Replace with your actual logo file
    st.markdown("### DataSage")
    st.write(
        "DataSage uses Azure AI Foundry and LangGraph to answer questions "
        "and generate output from Azure SQL DB."
    )
    st.markdown("---")
    st.subheader("Sample Questions")
    if st.button("Largest Customer Orders"):
        st.session_state.query="What are the top 5 largest orders by customer?"

# Add a GitHub icon in the top-right corner
github_link = """
<div style="position: fixed; top: 10px; right: 10px;">
    <a href="https://github.com/jonathanscholtes/Azure-AI-LangGraph-QnA-SQL-DB" target="_blank">
        <img src="https://cdn-icons-png.flaticon.com/512/25/25231.png" width="30">
    </a>
</div>
"""

components.html(github_link, height=50)

def update_text():
    response_text = ""
    for step in RelationalDataSystem().create_graph().stream(
    {"question": query}, stream_mode="updates"
):
        if 'generate_answer' in step:
            response_text = step['generate_answer']['answer']
            st.session_state.query_response = response_text


        if 'generate_dataframe' in step:
            st.session_state.df_response = step['generate_dataframe']['dataframe']
        print(step)

# Main section
st.subheader("Ask questions of your data:")
query = st.text_area("", height=80,key="query")

# Submit button
col1, col2 = st.columns([10, 1])
with col2:
    st.button("Submit",on_click=update_text)

st.caption("Response:")
with st.container(height=200):
    output_placeholder = st.markdown(st.session_state.query_response)

col1, col2 = st.columns([5, 5])

with col1:
    if "df_response" in st.session_state and st.session_state.df_response is not None:
        st.table(st.session_state.df_response)