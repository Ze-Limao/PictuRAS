from pydantic import BaseModel

from .core.messages.request_message import RequestMessage


class ObjectDetectionParameters(BaseModel):
    inputImageURI: str
    outputImageURI: str


ObjectDetectionRequestMessage = RequestMessage[ObjectDetectionParameters]
