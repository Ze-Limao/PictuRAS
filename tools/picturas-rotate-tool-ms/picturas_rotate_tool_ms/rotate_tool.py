from PIL import Image

from .core.tool import Tool
from .rotate_request_message import RotateParameters

class RotateTool(Tool):

    def __init__(
        self,
        default_angle: int = 90
    ) -> None:
        """
        Initialize the RotateTool.

        Args:
            default_angle (int): Default angle to rotate the image (90, 180, 270
        """
        self.default_angle = default_angle

    def apply(self, parameters: RotateParameters):
        """
        Apply rotation to the input image and save the result.

        Args:
            parameters (RotateParameters): Rotation parameters.
        """
        # Open the input image
        input_image = Image.open(parameters.inputImageURI).convert("RGBA")

        # Use the provided angle or default to the initialized value
        rotate_angle = parameters.rotateAngle if parameters.rotateAngle is not None else self.default_angle
        
        # Rotate the image
        rotated_image = input_image.rotate(rotate_angle)

        # Save the final image
        # Convert back to RGB for saving
        final_image = rotated_image.convert("RGB")
        final_image.save(parameters.outputImageURI)
