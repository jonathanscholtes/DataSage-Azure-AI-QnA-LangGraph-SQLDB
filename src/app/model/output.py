from pydantic import BaseModel

class DataFrameOutput(BaseModel):
    """Defines the expected structure of the AI-generated DataFrame."""
    columns: list[str]
    data: list[list[object]]