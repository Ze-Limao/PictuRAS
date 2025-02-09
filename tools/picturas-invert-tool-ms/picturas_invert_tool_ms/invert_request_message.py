from pydantic import BaseModel

from .core.messages.request_message import RequestMessage


class InvertParameters(BaseModel):
    inputImageURI: str
    outputImageURI: str


InvertRequestMessage = RequestMessage[InvertParameters]
