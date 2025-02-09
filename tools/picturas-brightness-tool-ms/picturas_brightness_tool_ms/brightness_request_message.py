from pydantic import BaseModel
from .core.messages.request_message import RequestMessage

class BrightnessParameters(BaseModel):
    inputImageURI: str
    outputImageURI: str
    brightnessLevel: float = 0.5


BrightnessRequestMessage = RequestMessage[BrightnessParameters]