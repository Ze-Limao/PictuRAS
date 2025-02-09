defmodule ProjectsApi.Projects.Tool do
  use ProjectsApi, :schema

  alias ProjectsApi.Projects.Project

  @required_fields ~w(procedure project_id position)a
  @optional_fields ~w(parameters)a

  @tools_file Application.compile_env(:projects, :tools)[:path] || "data/tools.json"

  def list_available_tools do
    @tools_file
    |> File.read!()
    |> Jason.decode!()
  end

  def list_available_prodecures do
    @tools_file
    |> File.read!()
    |> Jason.decode!()
    |> Enum.map(fn entry -> entry["procedure"] end)
  end

  schema "tools" do
    field :procedure, :string
    field :parameters, :map
    field :position, :integer

    belongs_to :project, Project

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tool, attrs) do
    tool
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:procedure, list_available_prodecures())
    |> validate_number(:position, greater_than: 0)
  end

  def order_by_position(tools) do
    Enum.sort_by(tools, & &1.position)
  end
end
