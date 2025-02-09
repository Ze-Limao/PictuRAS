import cv2
from .core.tool import Tool
from .resize_request_message import ResizeParameters

class ResizeTool(Tool):
    def __init__(self) -> None:
        pass

    def apply(self, parameters: ResizeParameters):
        """
        Apply resizing to the input image and save the result.

        Args:
            parameters (ResizeParameters): Resize parameters
        """
        # Open the input image
        input_image = cv2.imread(parameters.inputImageURI)

        # Use the provided resize width and height
        new_size = (parameters.resizeWidth, parameters.resizeHeight)

        # Resize the image
        resized_image = cv2.resize(input_image, new_size, interpolation=cv2.INTER_AREA)

        # Save the final image
        cv2.imwrite(parameters.outputImageURI, resized_image)
