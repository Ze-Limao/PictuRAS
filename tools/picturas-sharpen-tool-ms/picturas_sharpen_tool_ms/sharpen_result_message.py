from typing import Any

from pydantic import BaseModel

from .core.messages.result_message import ResultMessage
from .sharpen_request_message import SharpenRequestMessage


class SharpenResultOutput(BaseModel):
    type: str
    imageURI: str


class SharpenResultMessage(ResultMessage[SharpenResultOutput]):

    def __init__(self, request: SharpenRequestMessage, tool_result: Any, exception: Exception, *args):
        super().__init__(request, tool_result, exception, *args)
        if exception is None:
            self.output = SharpenResultOutput(
                type="image",
                imageURI=request.parameters.outputImageURI,
            )
