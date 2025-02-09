from typing import Any

from pydantic import BaseModel

from .core.messages.result_message import ResultMessage
from .bg_removal_request_message import BGRemovalRequestMessage


class BGRemovalResultOutput(BaseModel):
    type: str
    imageURI: str


class BGRemovalResultMessage(ResultMessage[BGRemovalResultOutput]):

    def __init__(self, request: BGRemovalRequestMessage, tool_result: Any, exception: Exception, *args):
        super().__init__(request, tool_result, exception, *args)
        if exception is None:
            self.output = BGRemovalResultOutput(
                type="image",
                imageURI=request.parameters.outputImageURI,
            )
