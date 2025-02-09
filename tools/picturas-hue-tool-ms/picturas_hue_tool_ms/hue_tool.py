from PIL import Image

from .core.tool import Tool
from .hue_request_message import HueParameters

class HueTool(Tool):

    def __init__(
        self,
        default_hue: float = 0.5
    ) -> None:
        """
        Initialize the HueTool.

        Args:
            default_hue (float): Default hue level (0.0 to 1.0).
        """
        self.default_hue = default_hue

    def apply(self, parameters: HueParameters):
        """
        Apply hue adjustment to the input image and save the result.

        Args:
            parameters (HueParameters): Hue parameters.
        """
        # Open the input image and convert to HSV
        input_image = Image.open(parameters.inputImageURI).convert("RGBA")
        image_hsv = input_image.convert("HSV")
        h, s, v = image_hsv.split()

        # Use the provided hue level or default to the initialized value
        hue_level = parameters.hueLevel if parameters.hueLevel is not None else self.default_hue

        scale_factor = int(hue_level * 255)
        h = h.point(lambda p: (p + scale_factor) % 256)

        # Adjust the hue
        hue_image = Image.merge("HSV", (h, s, v)).convert("RGB")

        # Save the final image
        hue_image.save(parameters.outputImageURI)
