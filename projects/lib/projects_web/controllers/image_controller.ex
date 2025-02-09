defmodule ProjectsApiWeb.ImageController do
  use ProjectsApiWeb, :controller

  alias ProjectsApi.Projects

  action_fallback ProjectsApiWeb.FallbackController

  def upload(conn, %{"id" => project_id} = params) do
    images = params["images"]

    # TODO: Validate images (Content-Type header, size, etc)
    with images <- store_images(images, project_id) do
      conn
      |> put_status(:created)
      |> render(:index, images: images)
    end
  end

  def download(conn, %{"id" => project_id, "image_id" => image_id}) do
    image = Projects.get_image!(project_id, image_id)
    mime_type = MIME.from_path(image.uri)

    case File.read(image.uri) do
      {:ok, image} ->
        conn
        |> put_resp_content_type(mime_type)
        |> send_resp(200, image)

      {:error, _} ->
        conn
        |> put_status(:not_found)
        |> json(%{errors: %{detail: "Not Found"}})
    end
  end

  def delete(conn, %{"id" => project_id, "image_id" => image_id}) do
    image = Projects.get_image!(project_id, image_id)

    with {1, nil} <- Projects.delete_image(project_id, image_id, image.uri) do
      send_resp(conn, :no_content, "")
    end
  end

  defp store_images(images, project_id) do
    Enum.map(images, fn {_, image} -> Projects.store_image!(image, project_id) end)
  end
end
