from .core.tool import Tool
from .sharpen_request_message import SharpenParameters
from PIL import Image, ImageFilter


class SharpenTool(Tool):

    def __init__(self) -> None:
       pass

    def apply(self, parameters: SharpenParameters):
        """
        Sharpe the image

        Args:
            parameters (SharpenParameters): Sharp parameters.
        """
        # Open the input image
        input_image = Image.open(parameters.inputImageURI).convert("RGBA")
        
        # Sharp the input image
        image_sharpen = input_image.filter(ImageFilter.SHARPEN)

        # Save the final image
        # Convert back to RGB for saving
        final_image = image_sharpen.convert("RGB")
        final_image.save(parameters.outputImageURI)
