from PIL import Image

from .core.tool import Tool
from .crop_request_message import CropParameters

class CropTool(Tool):

    def __init__(self) -> None:
        pass

    def apply(self, parameters: CropParameters):
        """
        Apply cropping to the input image and save the result.

        Args:
            parameters (CropParameters): Crop parameters.
        """
        # Open the input image
        input_image = Image.open(parameters.inputImageURI).convert("RGBA")

        # Use the provided crop coordinates
        crop_coords = (parameters.left, parameters.top, parameters.right, parameters.bottom)
        
        # Crop the image
        crop_image = input_image.crop(crop_coords)

        # Save the final image
        # Convert the image to RGB before saving
        final_image = crop_image.convert("RGB")
        final_image.save(parameters.outputImageURI)
