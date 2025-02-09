from pydantic import BaseModel
from .core.messages.request_message import RequestMessage

class BorderParameters(BaseModel):
    inputImageURI: str
    outputImageURI: str
    borderSize: int = 10
    borderColor: str = "#000000" 

BorderRequestMessage = RequestMessage[BorderParameters]
