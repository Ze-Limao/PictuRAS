from pydantic import BaseModel

from .core.messages.request_message import RequestMessage


class TextExtractionParameters(BaseModel):
    inputImageURI: str
    outputFilePath: str


TextExtractionRequestMessage = RequestMessage[TextExtractionParameters]