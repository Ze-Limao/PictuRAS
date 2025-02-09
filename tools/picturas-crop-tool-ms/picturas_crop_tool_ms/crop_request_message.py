from pydantic import BaseModel
from .core.messages.request_message import RequestMessage

class CropParameters(BaseModel):
    inputImageURI: str
    outputImageURI: str
    left: int
    top: int
    right: int
    bottom: int

CropRequestMessage = RequestMessage[CropParameters]
