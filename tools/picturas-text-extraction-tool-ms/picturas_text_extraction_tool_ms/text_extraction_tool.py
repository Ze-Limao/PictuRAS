import os
from PIL import Image
import pytesseract

class TextExtractionTool:
    def __init__(self, lang: str = "eng"):
        """
        Initialize the TextExtractionTool with the desired OCR language.

        Args:
            lang (str): Language for Tesseract OCR (default: "eng").
        """
        self.lang = lang

    def apply(self, parameters):
        """
        Extract text from an image and save it to a text file.

        Args:
            parameters (TextExtractionParameters): Contains inputImageURI and outputFilePath.
        """
        # Load the input image
        input_image = Image.open(parameters.inputImageURI)
        if input_image is None:
            raise ValueError(f"Failed to load image from {parameters.inputImageURI}")

        # Extract text from the image using Tesseract OCR
        extracted_text = pytesseract.image_to_string(input_image, lang=self.lang)

        # Determine the output file path (convert to .txt if necessary)
        input_base_name = os.path.splitext(os.path.basename(parameters.inputImageURI))[0]
        output_dir = os.path.dirname(parameters.outputFilePath) or "."
        output_file_path = os.path.join(output_dir, f"{input_base_name}.txt")

        # Create the output directory if it doesn't exist
        os.makedirs(output_dir, exist_ok=True)

        # Save the extracted text to the file
        with open(output_file_path, "w", encoding="utf-8") as text_file:
            text_file.write(extracted_text)

        print(f"Text extracted and saved to {output_file_path}")
