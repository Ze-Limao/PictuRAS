defmodule ProjectsApi.Projects.Image do
  use Ecto.Schema

  import Ecto.Changeset

  alias ProjectsApi.Projects.Project

  @required_fields ~w(id uri project_id)a
  @optional_fields ~w(type)a

  @types ~w(initial final)a
  @default_type :initial

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id

  schema "images" do
    field :uri, :string
    field :type, Ecto.Enum, values: @types, default: @default_type

    belongs_to :project, Project

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(image, attrs) do
    image
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_inclusion(:type, @types)
    |> validate_required(@required_fields)
  end

  def types, do: @types

  def initial?(image), do: image.type == :initial

  def final?(image), do: image.type == :final
end
