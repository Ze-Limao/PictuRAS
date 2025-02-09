from pydantic import BaseModel
from .core.messages.request_message import RequestMessage

class SaturationParameters(BaseModel):
    inputImageURI: str
    outputImageURI: str
    saturationLevel: float = 0.5


SaturationRequestMessage = RequestMessage[SaturationParameters]