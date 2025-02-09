from .core.tool import Tool
from .object_detection_request_message import ObjectDetectionParameters
from ultralytics import YOLO


class ObjectDetectionTool(Tool):

    def __init__(self) -> None:
       pass

    def apply(self, parameters: ObjectDetectionParameters):
        """
        Apply the object detection model to the input image and save the result.

        Args:
            parameters (ObjectDetectionParameters): Object detection parameters.
        """
        # Load the model
        model = YOLO("yolov8x.pt")

        # Apply the model
        input_image = parameters.inputImageURI
        results = model(input_image)

        # Save the final image
        output_image_path = parameters.outputImageURI
        results[0].save(output_image_path)
