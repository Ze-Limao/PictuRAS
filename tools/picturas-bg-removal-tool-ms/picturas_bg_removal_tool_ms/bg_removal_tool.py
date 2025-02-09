import cv2
from rembg import remove

from .core.tool import Tool
from .bg_removal_request_message import BGRemovalParameters


class BackgroundRemovalTool(Tool):

    def __init__(self) -> None:
        """
        Initialize the BackgroundRemovalTool.
        """
        
    def apply(self, parameters: BGRemovalParameters):
        """
        Remove the background from the input image and save the result.

        Args:
            parameters (BGRemovalParameters): Contains inputImageURI and outputImageURI.
        """
        # Open the input image
        input_image = cv2.imread(parameters.inputImageURI)

        # Remove the background
        final_image = remove(input_image)

        # Save the final image
        cv2.imwrite(parameters.outputImageURI, final_image)
