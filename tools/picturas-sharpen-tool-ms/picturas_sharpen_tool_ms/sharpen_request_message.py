from pydantic import BaseModel

from .core.messages.request_message import RequestMessage


class SharpenParameters(BaseModel):
    inputImageURI: str
    outputImageURI: str


SharpenRequestMessage = RequestMessage[SharpenParameters]
