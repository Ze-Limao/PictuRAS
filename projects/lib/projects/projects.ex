defmodule ProjectsApi.Projects do
  @moduledoc """
  The Projects context.
  """
  use ProjectsApi, :context

  alias ProjectsApi.Projects.{Image, Project, Tool}
  alias ProjectsApi.Accounts.{User, Guest}

  ## Projects

  @doc """
  Returns the list of projects for a given user.

  ## Examples

      iex> list_projects(123)
      [%Project{}, ...]

      iex> list_projects(456)
      []

  """
  def list_projects(user_id) do
    Project
    |> join(:left, [p], g in Guest, on: g.project_id == p.id)
    |> where([p, g], p.owner_id == ^user_id or g.user_id == ^user_id)
    |> order_by([p], desc: p.inserted_at)
    |> Repo.all()
    |> Repo.preload(guests: :user)
    |> Repo.preload([:images, :tools])
  end

  @doc """
  Gets a single project. It assumes the user requesting the project is the owner.

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_project!(123)
      %Project{}

      iex> get_project!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project!(id) do
    Project
    |> join(:left, [p], g in Guest, on: g.project_id == p.id)
    |> where([p, g], p.id == ^id)
    |> Repo.one!()
    |> Repo.preload(guests: :user)
    |> Repo.preload([:images, :tools])
  end

  @doc """
  Gets a single project. The project will only be returned if the user requesting is the owner.

  Returns `nil` if the Project does not exist.

  ## Examples

      iex> get_project(123)
      %Project{}

      iex> get_project(456)
      nil

  """
  def get_project(id) do
    Project
    |> join(:left, [p], g in Guest, on: g.project_id == p.id)
    |> where([p, g], p.id == ^id)
    |> Repo.one()
    |> Repo.preload(guests: :user)
    |> Repo.preload([:images, :tools])
  end

  @doc """
  Gets a single project. The project will only be returned if the user requesting
  is either the owner or a guest.

  ## Examples

      iex> get_project!(123, 456)
      %Project{}

      iex> get_project!(123, 789)
      ** (Ecto.NoResultsError)

  """
  def maybe_get_project!(id, user_id) do
    Project
    |> join(:left, [p], g in Guest, on: g.project_id == p.id)
    |> where([p, g], p.id == ^id and (p.owner_id == ^user_id or g.user_id == ^user_id))
    |> Repo.one!()
    |> Repo.preload(guests: :user)
    |> Repo.preload([:images, :tools])
  end

  @doc """
  Creates a project.

  ## Examples

      iex> create_project(%{field: value})
      {:ok, %Project{}}

      iex> create_project(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project(attrs \\ %{}) do
    %Project{}
    |> Project.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a project.

  ## Examples

      iex> update_project(project, %{field: new_value})
      {:ok, %Project{}}

      iex> update_project(project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project(%Project{} = project, attrs) do
    project
    |> Project.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a project's state and completion percentage.

  ## Examples

      iex> update_project_state(123, %{state: :processing, completion: 50})
      {:ok, %Project{}}

      iex> update_project_state(456, %{state: :processing, completion: 101})
      {:error, %Ecto.Changeset{}}

  """
  def update_project_state(project_id, attrs) do
    project = get_project!(project_id)

    project
    |> Project.state_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a project.

  ## Examples

      iex> delete_project(project)
      {:ok, %Project{}}

      iex> delete_project(project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project(%Project{} = project) do
    delete_images(project.id)
    Repo.delete(project)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.

  ## Examples

      iex> change_project(project)
      %Ecto.Changeset{data: %Project{}}

  """
  def change_project(%Project{} = project, attrs \\ %{}) do
    Project.changeset(project, attrs)
  end

  ## Guests

  def invite_user(%User{} = user, %Project{} = project) do
    %Guest{}
    |> Guest.changeset(%{user_id: user.id, project_id: project.id})
    |> Repo.insert()
  end

  def revoke_user(%User{} = user, %Project{} = project) do
    Guest
    |> where([g], g.user_id == ^user.id and g.project_id == ^project.id)
    |> Repo.delete_all()
  end

  ## Images

  @uploads_dir Application.compile_env(:projects, :uploads)[:path] || "../images/"

  @doc """
  Stores an image in the filesystem and creates a new Image record.

  Returns the created image id.
  """
  def store_image!(%Plug.Upload{path: path, filename: filename}, project_id) do
    dest_dir = Path.join(@uploads_dir, project_id)
    File.mkdir_p!(dest_dir)

    image_id = Ecto.UUID.generate()
    unique_filename = image_id <> Path.extname(filename)
    dest = Path.join(dest_dir, unique_filename)
    File.cp!(path, dest)

    create_image!(project_id, image_id, dest)
  end

  defp create_image!(project_id, image_id, uri) do
    %Image{}
    |> Image.changeset(%{id: image_id, project_id: project_id, uri: uri})
    |> Repo.insert!()
  end

  def upsert_final_image!(project_id, uri) do
    case Repo.get_by(Image, uri: uri) do
      nil -> create_final_image!(project_id, uri)
      image -> image
    end
  end

  defp create_final_image!(project_id, uri) do
    image_id = Ecto.UUID.generate()

    %Image{}
    |> Image.changeset(%{id: image_id, project_id: project_id, uri: uri, type: "final"})
    |> Repo.insert!()
  end

  @doc """
  Gets a single image.

  Raises `Ecto.NoResultsError` if the Image does not exist.

  ## Examples

      iex> get_image!(123, 456)
      %Image{}

      iex> get_image!(123, 789)
      ** (Ecto.NoResultsError)

  """
  def get_image!(project_id, image_id) do
    Image
    |> where([i], i.project_id == ^project_id and i.id == ^image_id)
    |> Repo.one!()
  end

  @doc """
  Deletes an image.

  ## Examples

      iex> delete_image(123, 456, "image.jpg")
      {:ok, %Image{}}

      iex> delete_image(123, 789, "image.jpg")
      {:error, %Ecto.Changeset{}}

  """
  def delete_image(project_id, image_id, uri) do
    delete_file(uri)

    Image
    |> where([i], i.project_id == ^project_id and i.id == ^image_id)
    |> Repo.delete_all()
  end

  defp delete_file(uri), do: File.rm(uri)

  defp delete_images(project_id) do
    delete_dir(project_id)

    Image
    |> where([i], i.project_id == ^project_id)
    |> Repo.delete_all()
  end

  defp delete_dir(project_id) do
    dest_dir = Path.join(@uploads_dir, project_id)
    File.rm_rf!(dest_dir)
  end

  def project_path(project_id) do
    Path.join(@uploads_dir, project_id)
  end

  ## Tools

  @doc """
  Override the tools for a project. Meaning, it will delete all the tools
  associated with the project and create new ones.

  If any of the tools fail to be created, the transaction is rolled back
  and none of the tools are created.
  """
  def override_tools(tools, project_id) when is_list(tools) do
    Tool
    |> where([t], t.project_id == ^project_id)
    |> Repo.delete_all()

    multi =
      Enum.with_index(tools)
      |> Enum.reduce(Ecto.Multi.new(), fn {tool, index}, multi_acc ->
        operation = {:create_tool, index}

        tool = Map.put(tool, "project_id", project_id)
        changeset = Tool.changeset(%Tool{}, tool)

        Ecto.Multi.insert(multi_acc, operation, changeset)
      end)

    case Repo.transaction(multi) do
      {:ok, tools} ->
        {:ok, tools}

      {:error, _reason, changeset, _actions} ->
        {:error, changeset}
    end
  end
end
