from pydantic import BaseModel
from typing import List, Dict, Any

class DataFrameOutput(BaseModel):
    columns: List[str]
    data: List[List[object]]


class DataFrameMetadata(BaseModel):
    columns: List[str]
    dtypes: List[str]
    sample_data: List[Dict[str, Any]]