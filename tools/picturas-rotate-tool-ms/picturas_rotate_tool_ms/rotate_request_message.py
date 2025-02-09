from pydantic import BaseModel
from .core.messages.request_message import RequestMessage

class RotateParameters(BaseModel):
    inputImageURI: str
    outputImageURI: str
    rotateAngle: int = 0

RotateRequestMessage = RequestMessage[RotateParameters]
