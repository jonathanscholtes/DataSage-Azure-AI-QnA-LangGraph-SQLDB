from .init import llm, db
from langgraph.graph import MessagesState
from langgraph.graph import StateGraph, END,START
from langchain_core.output_parsers import StrOutputParser
from langchain.prompts import PromptTemplate
from langchain import hub
from langchain_community.tools.sql_database.tool import QuerySQLDatabaseTool
import pandas as pd
import numpy as np
from typing_extensions import TypedDict, Annotated
from model.output import DataFrameOutput
from langchain_core.output_parsers import JsonOutputParser
from langchain.prompts import PromptTemplate
from langchain.schema import AIMessage

# Define the structured output as a dictionary
class QueryOutput(TypedDict):
    """Generated SQL query."""
    query: Annotated[str, ..., "Syntactically valid SQL query."]


class AgentState(MessagesState):
    # Final structured response from the agent
    question: str
    query: str
    result: str
    dataframe: pd.DataFrame
    answer: str


class RelationalDataSystem():

    def __init__(self):
         self.query_prompt_template = hub.pull("langchain-ai/sql-query-system-prompt")

    def write_query(self,state: AgentState):
        """Generate SQL query to fetch information."""
        prompt = self.query_prompt_template.invoke(
            {
                "dialect": db.dialect,
                "top_k": 10,
                "table_info": db.get_table_info(),
                "input": state["question"],
            }
        )
        structured_llm = llm.with_structured_output(QueryOutput)
        result = structured_llm.invoke(prompt)
        return {"query": result["query"]}
    

    def execute_query(self,state: AgentState):
        """Execute SQL query."""
        execute_query_tool = QuerySQLDatabaseTool(db=db)
        return {"result": execute_query_tool.invoke(state["query"])}
    
    def generate_dataframe(self, state: AgentState):
        """Create a Pandas DataFrame using retrieved SQL information as context."""
        
        parser = JsonOutputParser(pydantic_object=DataFrameOutput)

        prompt_template = PromptTemplate(
        template="""
        You are an AI assistant that converts SQL query results into the specifed JSON output format.

        Given the following user SQL query and its corresponding result, return a well-formatted JSON document.

         ### User SQL Query:
         {query}

         ### SQL Result:
        {result}

        ### JSON Output Format:
        {format_instructions}

        Instructions:
        1. Parse the SQL result correctly. It is formatted as a string representation of a list of tuples.
        2. Extract column names from the SQL query if available (look for 'AS ColumnName' aliases).
        3. If no alias exists, use a generic name like "Result".
        4. Ensure numbers remain as numbers and text remains as text.
        """,
        input_variables=["query", "result"],
        partial_variables={"format_instructions": parser.get_format_instructions()}
        )

        prompt = prompt_template.format(query=state["query"], result=state["result"])

        response = llm.invoke(prompt)

        if isinstance(response, AIMessage): 
            response_text = response.content
        else:
            response_text = str(response)

        response_text = response_text.replace("json\n", "").strip("```").strip()

        parsed_response = DataFrameOutput(**parser.parse(response_text))
        # Convert response to Pandas DataFrame
        df = pd.DataFrame(parsed_response.data, columns=parsed_response.columns)

        return {"dataframe": df}

    def generate_answer(self,state: AgentState):
        """Answer question using retrieved information as context."""
        prompt = (
            "Given the following user question, corresponding SQL query, "
            "and SQL result, answer the user question.\n\n"
            f'Question: {state["question"]}\n'
            f'SQL Query: {state["query"]}\n'
            f'SQL Result: {state["result"]}'
        )
        response = llm.invoke(prompt)
        return {"answer": response.content}


    def create_graph(self):

        # Define a new graph
        workflow = StateGraph(AgentState)

        workflow.add_node("write_query", self.write_query)
        workflow.add_node("execute_query", self.execute_query)
        workflow.add_node("generate_answer", self.generate_answer)
        workflow.add_node("generate_dataframe", self.generate_dataframe)

        workflow.add_edge(START, "write_query")
        workflow.add_edge("write_query", "execute_query")
        workflow.add_edge("execute_query", "generate_answer")
        workflow.add_edge("execute_query", "generate_dataframe")
        workflow.add_edge("generate_answer", END)

        
        graph = workflow.compile()
        return graph