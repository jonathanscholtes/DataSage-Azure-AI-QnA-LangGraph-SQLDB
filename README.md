
 [!WARNING]  
> **This project is currently in active development and may contain breaking changes.**  
> Updates and modifications are being made frequently, which may impact stability or functionality. This notice will be removed once development is complete and the project reaches a stable release.


# DataSage: Azure AI Question Answering System over SQL Data with LangGraph

![diagram](./media/logo_small.png)


## Overview

DataSage is a question-answering system over tabular (SQL) data, designed around agent-based workflows that facilitate seamless data exchange between AI agents and the user. It leverages Azure AI Foundry, LangGraph, Azure SQL DB, and Streamlit to enable natural language interactions with SQL databases, retrieving precise and contextually relevant answers powered by AI. The project is built off of the LangChain tutorial [Build a Question/Answering system over SQL data](https://python.langchain.com/docs/tutorials/sql_qa/).

At its core, LangGraph orchestrates a network of AI agents, each responsible for a specific task—query generation, SQL execution, response summarization, and visualization. These agents pass data to one another, ensuring efficient processing before delivering insights to the user.

The system integrates Azure AI Foundry for model inference, Azure SQL DB for structured data storage and retrieval, and Streamlit for an intuitive front-end experience.

Additionally, the project includes Bicep scripts for automated deployment of necessary Azure resources, ensuring a seamless and reproducible setup.


![diagram](./media/largest_orders.png)

## Key Features

- **Natural Language Querying:** Users can input questions in plain English, and the system converts them into SQL queries.

- **AI-Powered Responses:** Uses LLMs to interpret SQL results and generate human-readable answers.

- **LangGraph Integration:** Implements a structured, graph-based approach to managing AI workflows and SQL execution.

- **Azure AI Foundry:** Enhances question understanding and response generation.

- **Azure SQL DB:** Provides scalable and secure storage for structured data.

- **Streamlit UI:** A lightweight, interactive interface for querying and visualizing results.

- **Deployment:** Uses  Bicep to provision and configure Azure resources.

---

## Agentic AI and LangGraph

### What is Agentic AI?
Agentic AI refers to AI systems designed to operate autonomously, making decisions and executing tasks based on structured workflows and dynamic interactions. Unlike traditional machine learning models that simply provide outputs, agentic AI systems can iterate through multi-step processes, leverage different tools, and adapt based on the context of the task.

In the case of DataSage, agentic AI is used to:
- Understand and interpret user queries.
- Generate and execute SQL queries dynamically.
- Analyze retrieved data and summarize it in human-readable responses.
- Suggest appropriate visualizations based on query results.

### How LangGraph Enhances AI Workflows
[LangGraph](https://python.langchain.com/docs/langgraph/) is a framework built on top of [LangChain](https://python.langchain.com) that enables graph-based orchestration of AI workflows. Instead of executing tasks in a linear sequence, LangGraph allows for:
- **Parallel Execution:** Multiple tasks, such as query generation and data visualization, can run simultaneously.
- **State Management:** Ensures AI agents retain context across multi-step interactions.
- **Flexible Workflow Design:** Enables complex branching logic, allowing different AI components to collaborate effectively.

In DataSage, LangGraph is used to structure the AI workflow, ensuring smooth transitions between query generation, execution, response synthesis, and visualization. By leveraging LangGraph, DataSage provides a robust and scalable approach to AI-powered SQL interactions.


### LangGraph Workflow  

![diagram](./media/graph.png)

The diagram illustrates the **LangGraph-based AI workflow** in DataSage for answering SQL queries and generating visualizations:  

1. **Start (`__start__`)** → Initiates the AI-driven SQL query process.  
2. **Write Query (`write_query`)** → AI formulates an SQL query from the user’s natural language input.  
3. **Execute Query (`execute_query`)** → Runs the query and branches into two parallel paths:  
   - **Generate Answer (`generate_answer`)** → Summarizes results in a human-readable response.  
   - **Generate DataFrame (`generate_dataframe`)** → Converts results into a Pandas DataFrame.  
4. **Suggest Visualization (`suggest_visualization`)** → AI selects the best visualization type for the data.  
5. **End (`__end__`)** → Completes the workflow, returning both **text and visual insights**.  

---

## Architecture

The architecture of DataSage consists of:

- **Frontend:** The frontend of DataSage is built using Streamlit, providing an intuitive and interactive interface for users to query and explore SQL data seamlessly. The UI is designed to be lightweight yet powerful, enabling both technical and non-technical users to interact with structured databases using natural language.

- **Backend:** Built with Python and LangGraph, the backend handles query parsing, SQL execution, and AI-driven response generation. This demo features a tightly integrated agent execution within the Streamlit application. For a more scalable and production-ready architecture, consider [Designing a Robust and Secure GenAI RAG Architecture with React, Python FastAPI, and Azure](https://github.com/jonathanscholtes/Azure-AI-RAG-Architecture-React-FastAPI-and-Cosmos-DB-Vector-Store)

- **Database:** Uses Azure SQL DB serverless, a cost-effective and scalable solution for storing and retrieving structured data. The serverless model automatically scales compute resources based on demand, optimizing performance and cost. This ensures seamless query execution and data retrieval without the need for manual scaling or provisioning.

- **AI Processing:** Azure AI Foundry offers a unified platform for enterprise AI operations, model development, and application integration, enabling chat completion, agent-driven intelligence, and model management. It enhances natural language understanding and response generation, ensuring accurate query interpretation and seamless AI-driven insights

- **Infrastructure Deployment:** Powershell and Bicep scripts deploy and configure required Azure resources.

![design](./media/design.png)


## Requirements
- Azure subscription for deploying Azure GenAI RAG Application.
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/get-started-with-azure-cli) (Command Line Interface)
- Python 3.11.4 installed on development environment.
- An IDE for Development, such as [VS Code](https://code.visualstudio.com/download)


## Usage

Follow these steps to set up and deploy the solution:

### 1. Clone the Repository from GitHub:  
Begin by cloning the repository to your local machine using the following command:

```bash
git clone https://github.com/jonathanscholtes/DataSage-Azure-AI-QnA-LangGraph-SQLDB.git
cd DataSage-Azure-AI-QnA-LangGraph-SQLDB
```

### 2. Deploy the Solution Using Bicep:  
Navigate to the deployment directory:

```bash
cd infra
```

Then, use the following PowerShell command to deploy the solution. Make sure to replace the placeholders with your actual subscription name, Azure Region (ResourceGroupLocation), Azure SQL DB username, and password:

**PowerShell**
```bash
.\deploy.ps1 -Subscription '[Subscription Name]' -Location 'eastus2' -SQLAdminUser '[User for SQL DB]' -SQLPassword '[Password to Create for SQL DB]'
```
This script will provision the necessary resources in your Azure subscription according to the specified parameters. The deployment may take upto **20 minutes** to provision all Azure resources.

### 3. Allow Client IP Access to Azure SQL DB
After deployment, you must grant your local environment access to the Azure SQL Database to run the Streamlit application. 
To do this, add your client IP address to the database firewall rules.

- Log in to the Azure portal.
- Navigate to your Azure SQL database.
- Click on **Set Server firewall**
- Add your current client IP address to the list of allowed addresses.

![firewall](./media/sqldb_firewall.png)

![clientid](./media/sqldb_network_rule.png)


### 4. Configure Environment Variables

To run DataSage, you need to create a .env file and populate it with the required environment variables. Follow these steps:

1. In the Streamlit project under [src/app](src/app), create a new file named .env.
2. Add the following variables and update them with your Azure service details (replace the placeholders with your Azure SQL DB username, password and Azure AI Service endpoint details):

```
AZURE_OPENAI_API_KEY="Key from deployed Azure AI Service"
AZURE_OPENAI_ENDPOINT="Endpoint from deployed Azure AI Service"
AZURE_OPENAI_MODEL="gpt-4o"
AZURE_OPENAI_API_VERSION="2024-08-01-preview"
AZURE_SQL_CONNECTION_STRING="mssql+pymssql://sqlAdmin:sqlPassword@sql-agentqna-demo-[randomnumber].database.windows.net:1433/sqldb-agentqna"
AZURE_SQL_DATABASE_SCHEMA="SalesLT"
```

### 5. Set Up and Run the Streamlit Application

Navigate to the Streamlit application directory [src/app](src/app) and follow these steps:

- Create a Python Virtual Environment:

```
python -m venv venv
```
- Activate the Virtual Environment and Install Dependencies:
```
venv\Scripts\activate # On macOS/Linux, use `source venv/bin/activate`
python -m pip install -r requirements.txt
```
- Start DataSage:
```
streamlit run app.py
```

This will launch the application in your browser, allowing you to interact with the SQL database using natural language queries.

![diagram](./media/largest_orders.png)


---

## Clean-Up

After completing testing, ensure to delete any unused Azure resources or remove the entire Resource Group to avoid incurring additional charges.


## License
This project is licensed under the [MIT License](MIT.md), granting permission for commercial and non-commercial use with proper attribution.


## Disclaimer
This demo application is intended solely for educational and demonstration purposes. It is provided "as-is" without any warranties, and users assume all responsibility for its use.
