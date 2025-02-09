from .core.tool import Tool
from .invert_request_message import InvertParameters
from PIL import Image, ImageOps

class InvertTool(Tool):

    def __init__(self) -> None:
       pass

    def apply(self, parameters: InvertParameters):
        """
        Invert the image colors

        Args:
            parameters (InvertParameters): Invert parameters.
        """
        # Open the input image
        input_image = Image.open(parameters.inputImageURI).convert("RGB")

        # Invert the image
        image_invert = ImageOps.invert(input_image)

        # Save the final image
        # Convert back to RGB for saving
        final_image = image_invert.convert("RGB")
        final_image.save(parameters.outputImageURI)
