from typing import Any

from pydantic import BaseModel

from .core.messages.result_message import ResultMessage
from .invert_request_message import InvertRequestMessage


class InvertResultOutput(BaseModel):
    type: str
    imageURI: str


class InvertResultMessage(ResultMessage[InvertResultOutput]):

    def __init__(self, request: InvertRequestMessage, tool_result: Any, exception: Exception, *args):
        super().__init__(request, tool_result, exception, *args)
        if exception is None:
            self.output = InvertResultOutput(
                type="image",
                imageURI=request.parameters.outputImageURI,
            )
