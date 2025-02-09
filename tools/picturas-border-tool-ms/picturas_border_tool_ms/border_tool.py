from PIL import Image, ImageOps

from .core.tool import Tool
from .border_request_message import BorderParameters

class BorderTool(Tool):

    def __init__(
        self,
        default_border_size: int = 10,
        default_border_color: str = "#000000"
    ) -> None:
        self.default_border_size = default_border_size
        self.default_border_color = default_border_color

    def apply(self, parameters: BorderParameters):
        input_image = Image.open(parameters.inputImageURI).convert("RGBA")

        border_size = parameters.borderSize if parameters.borderSize is not None else self.default_border_size
        border_color = parameters.borderColor if parameters.borderColor is not None else self.default_border_color

        bordered_image = ImageOps.expand(input_image, border=border_size, fill=border_color)

        final_image = bordered_image.convert("RGB")
        final_image.save(parameters.outputImageURI)
