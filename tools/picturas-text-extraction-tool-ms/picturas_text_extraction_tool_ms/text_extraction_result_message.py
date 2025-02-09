from typing import Any

from pydantic import BaseModel

from .core.messages.result_message import ResultMessage
from .text_extraction_request_message import TextExtractionRequestMessage


class TextExtractionResultOutput(BaseModel):
    type: str
    filePath: str


class TextExtractionResultMessage(ResultMessage[TextExtractionResultOutput]):

    def __init__(self, request: TextExtractionRequestMessage, tool_result: Any, exception: Exception, *args):
        super().__init__(request, tool_result, exception, *args)
        if exception is None:
            self.output = TextExtractionResultOutput(
                type="text",
                filePath=request.parameters.outputFilePath,
            )
