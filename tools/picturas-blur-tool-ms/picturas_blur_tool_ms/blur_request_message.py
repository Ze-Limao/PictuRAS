from pydantic import BaseModel

from .core.messages.request_message import RequestMessage


class BlurParameters(BaseModel):
    inputImageURI: str
    outputImageURI: str


BlurRequestMessage = RequestMessage[BlurParameters]
