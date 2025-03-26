from dotenv import load_dotenv
from os import environ
from langchain_openai import AzureChatOpenAI
from langchain_community.utilities import SQLDatabase
from sqlalchemy import create_engine

# Load environment variables from .env file
load_dotenv(override=True)

# Initialize the AzureChatOpenAI model
llm: AzureChatOpenAI | None = None
db: SQLDatabase | None = None

def initialize_llm():
    """Initialize the Azure Chat OpenAI model with specified parameters."""
    global llm, db

    

    llm = AzureChatOpenAI(
        temperature=0,
        azure_deployment=environ["AZURE_OPENAI_MODEL"],
        api_version=environ["AZURE_OPENAI_API_VERSION"]
    )

    engine = create_engine(environ["AZURE_SQL_CONNECTION_STRING"])
    db = SQLDatabase(engine, schema=environ["AZURE_SQL_DATABASE_SCHEMA"])
 


initialize_llm()