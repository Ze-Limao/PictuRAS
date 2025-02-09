from typing import Any

from pydantic import BaseModel

from .core.messages.result_message import ResultMessage
from .saturation_request_message import SaturationRequestMessage


class SaturationResultOutput(BaseModel):
    type: str  
    imageURI: str


class SaturationResultMessage(ResultMessage[SaturationResultOutput]):
    def __init__(self, request: SaturationRequestMessage, tool_result: Any, exception: Exception, *args):
        super().__init__(request, tool_result, exception, *args)
        if exception is None:
            self.output = SaturationResultOutput(
                type="image",
                imageURI=request.parameters.outputImageURI,
            )
