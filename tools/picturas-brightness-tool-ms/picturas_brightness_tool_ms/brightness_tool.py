from PIL import Image, ImageEnhance

from .core.tool import Tool
from .brightness_request_message import BrightnessParameters

class BrightnessTool(Tool):

    def __init__(
        self,
        default_brightness: float = 0.5
    ) -> None:
        """
        Initialize the BrightnessTool.

        Args:
            default_brightness (float): Default brightness level (0.0 to 1.0).
        """
        self.default_brightness = default_brightness

    def apply(self, parameters: BrightnessParameters):
        """
        Apply brightness adjustment to the input image and save the result.

        Args:
            parameters (BrightnessParameters): Brightness parameters.
        """
        # Open the input image
        input_image = Image.open(parameters.inputImageURI).convert("RGBA")

        # Use the provided brightness level or default to the initialized value
        brightness_level = parameters.brightnessLevel if parameters.brightnessLevel is not None else self.default_brightness

        # Adjust the brightness
        enhancer = ImageEnhance.Brightness(input_image)
        enhanced_image = enhancer.enhance(brightness_level * 2)

        # Save the final image
        # Convert back to RGB for saving
        final_image = enhanced_image.convert("RGB")
        final_image.save(parameters.outputImageURI)
