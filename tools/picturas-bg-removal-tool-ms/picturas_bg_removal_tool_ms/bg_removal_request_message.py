from pydantic import BaseModel

from .core.messages.request_message import RequestMessage


class BGRemovalParameters(BaseModel):
    inputImageURI: str
    outputImageURI: str


BGRemovalRequestMessage = RequestMessage[BGRemovalParameters]