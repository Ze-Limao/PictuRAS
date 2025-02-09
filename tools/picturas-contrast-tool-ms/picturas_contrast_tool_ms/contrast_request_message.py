from pydantic import BaseModel
from .core.messages.request_message import RequestMessage

class ContrastParameters(BaseModel):
    inputImageURI: str
    outputImageURI: str
    contrastLevel: float = 0.5


ContrastRequestMessage = RequestMessage[ContrastParameters]