from PIL import Image, ImageEnhance

from .core.tool import Tool
from .saturation_request_message import SaturationParameters

class SaturationTool(Tool):

    def __init__(
        self,
        default_saturation: float = 0.5
    ) -> None:
        """
        Initialize the SaturationTool.

        Args:
            default_saturation (float): Default saturation level (0.0 to 1.0).
        """
        self.default_saturation = default_saturation

    def apply(self, parameters: SaturationParameters):
        """
        Apply saturation adjustment to the input image and save the result.

        Args:
            parameters (SaturationParameters): Saturation parameters.
        """
        # Open the input image
        input_image = Image.open(parameters.inputImageURI).convert("RGBA")

        # Use the provided saturation level or default to the initialized value
        saturation_level = parameters.saturationLevel if parameters.saturationLevel is not None else self.default_saturation

        # Adjust the saturation
        enhancer = ImageEnhance.Color(input_image)
        enhanced_image = enhancer.enhance(saturation_level * 2)

        # Save the final image
        # Convert back to RGB for saving
        final_image = enhanced_image.convert("RGB")
        final_image.save(parameters.outputImageURI)
