from typing import Any

from pydantic import BaseModel

from .core.messages.result_message import ResultMessage
from .blur_request_message import BlurRequestMessage


class BlurResultOutput(BaseModel):
    type: str
    imageURI: str


class BlurResultMessage(ResultMessage[BlurResultOutput]):

    def __init__(self, request: BlurRequestMessage, tool_result: Any, exception: Exception, *args):
        super().__init__(request, tool_result, exception, *args)
        if exception is None:
            self.output = BlurResultOutput(
                type="image",
                imageURI=request.parameters.outputImageURI,
            )
