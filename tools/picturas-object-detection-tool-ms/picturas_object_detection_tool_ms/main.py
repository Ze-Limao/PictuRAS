import logging

from .config import PICTURAS_LOG_LEVEL
from .core.message_processor import MessageProcessor
from .core.message_queue_setup import message_queue_connect
from .object_detection_request_message import ObjectDetectionRequestMessage
from .object_detection_result_message import ObjectDetectionResultMessage
from .object_detection_tool import ObjectDetectionTool

# Logging setup
LOG_FORMAT = '%(asctime)s [%(levelname)s] %(message)s'
logging.basicConfig(level=PICTURAS_LOG_LEVEL, format=LOG_FORMAT)

LOGGER = logging.getLogger(__name__)

if __name__ == "__main__":
    connection, channel = message_queue_connect()

    tool = ObjectDetectionTool()  # Use the new tool class
    request_msg_class = ObjectDetectionRequestMessage
    result_msg_class = ObjectDetectionResultMessage

    message_processor = MessageProcessor(tool, request_msg_class, result_msg_class, channel)

    try:
        message_processor.start()
    except KeyboardInterrupt:
        message_processor.stop()

    connection.close()
