import logging

from .config import PICTURAS_LOG_LEVEL
from .core.message_processor import MessageProcessor
from .core.message_queue_setup import message_queue_connect
from .bg_removal_request_message import BGRemovalRequestMessage
from .bg_removal_result_message import BGRemovalResultMessage
from .bg_removal_tool import BackgroundRemovalTool

# Logging setup
LOG_FORMAT = '%(asctime)s [%(levelname)s] %(message)s'
logging.basicConfig(level=PICTURAS_LOG_LEVEL, format=LOG_FORMAT)

LOGGER = logging.getLogger(__name__)

if __name__ == "__main__":
    connection, channel = message_queue_connect()

    tool = BackgroundRemovalTool()
    request_msg_class = BGRemovalRequestMessage
    result_msg_class = BGRemovalResultMessage

    message_processor = MessageProcessor(tool, request_msg_class, result_msg_class, channel)

    try:
        message_processor.start()
    except KeyboardInterrupt:
        message_processor.stop()

    connection.close()