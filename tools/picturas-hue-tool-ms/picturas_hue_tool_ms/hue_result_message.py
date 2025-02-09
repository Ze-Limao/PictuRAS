from typing import Any

from pydantic import BaseModel

from .core.messages.result_message import ResultMessage
from .hue_request_message import HueRequestMessage


class HueResultOutput(BaseModel):
    type: str  
    imageURI: str


class HueResultMessage(ResultMessage[HueResultOutput]):
    def __init__(self, request: HueRequestMessage, tool_result: Any, exception: Exception, *args):
        super().__init__(request, tool_result, exception, *args)
        if exception is None:
            self.output = HueResultOutput(
                type="image",
                imageURI=request.parameters.outputImageURI,
            )
