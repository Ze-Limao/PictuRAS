from typing import Any

from pydantic import BaseModel

from .core.messages.result_message import ResultMessage
from .object_detection_request_message import ObjectDetectionRequestMessage


class ObjectDetectionResultOutput(BaseModel):
    type: str
    imageURI: str


class ObjectDetectionResultMessage(ResultMessage[ObjectDetectionResultOutput]):

    def __init__(self, request: ObjectDetectionRequestMessage, tool_result: Any, exception: Exception, *args):
        super().__init__(request, tool_result, exception, *args)
        if exception is None:
            self.output = ObjectDetectionResultOutput(
                type="image",
                imageURI=request.parameters.outputImageURI,
            )
