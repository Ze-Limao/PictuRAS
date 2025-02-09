from pydantic import BaseModel
from .core.messages.request_message import RequestMessage

class HueParameters(BaseModel):
    inputImageURI: str
    outputImageURI: str
    hueLevel: float = 0.5


HueRequestMessage = RequestMessage[HueParameters]