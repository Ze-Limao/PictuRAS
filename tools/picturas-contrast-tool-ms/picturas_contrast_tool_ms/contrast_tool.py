from PIL import Image, ImageEnhance

from .core.tool import Tool
from .contrast_request_message import ContrastParameters

class ContrastTool(Tool):

    def __init__(
        self,
        default_contrast: float = 0.5
    ) -> None:
        """
        Initialize the ContrastTool.

        Args:
            default_contrast (float): Default contrast level (0.0 to 1.0).
        """
        self.default_contrast = default_contrast

    def apply(self, parameters: ContrastParameters):
        """
        Apply contrast adjustment to the input image and save the result.

        Args:
            parameters (ContrastParameters): Contrast parameters.
        """
        # Open the input image
        input_image = Image.open(parameters.inputImageURI).convert("RGBA")

        # Use the provided contrast level or default to the initialized value
        contrast_level = parameters.contrastLevel if parameters.contrastLevel is not None else self.default_contrast

        # Adjust the contrast
        enhancer = ImageEnhance.Contrast(input_image)
        enhanced_image = enhancer.enhance(contrast_level * 2)

        # Save the final image
        # Convert back to RGB for saving
        final_image = enhanced_image.convert("RGB")
        final_image.save(parameters.outputImageURI)
