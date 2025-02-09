defmodule ProjectsApiWeb.ImageJSON do
  alias ProjectsApi.Projects.Image

  @doc """
  Renders a list of images.
  """
  def index(%{images: images}) do
    %{data: for(image <- images, do: data(image))}
  end

  defp data(%Image{} = image) do
    %{
      id: image.id
    }
  end
end
