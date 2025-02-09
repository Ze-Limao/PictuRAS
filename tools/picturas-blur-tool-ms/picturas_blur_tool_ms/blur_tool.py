from .core.tool import Tool
from .blur_request_message import BlurParameters
from PIL import Image, ImageFilter

class BlurTool(Tool):

    def __init__(self) -> None:
       pass

    def apply(self, parameters: BlurParameters):
        """
        Apply the blur to an Image

        Args:
            parameters (BlurParameters): Blur parameters.
        """
        # Open the input image
        input_image = Image.open(parameters.inputImageURI).convert("RGBA")

        # Blur the image
        imagem_blur = input_image.filter(ImageFilter.BLUR)

        # Save the final image
        # Convert back to RGB for saving
        final_image = imagem_blur.convert("RGB")
        final_image.save(parameters.outputImageURI)
