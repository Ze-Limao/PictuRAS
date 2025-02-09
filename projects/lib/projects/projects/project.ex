defmodule ProjectsApi.Projects.Project do
  use ProjectsApi, :schema

  alias ProjectsApi.Accounts.{User, Guest}
  alias ProjectsApi.Projects.{Image, Tool}

  @required_fields ~w(owner_id)a
  @optional_fields ~w(name)a
  @updatable_fields ~w(name)a
  @internal_fields ~w(state completion)a

  @states ~w(idle processing canceled failed)a
  @default_state :idle

  schema "projects" do
    field :name, :string
    field :state, Ecto.Enum, values: @states, default: @default_state
    field :completion, :integer, default: 0

    belongs_to :owner, User
    has_many :guests, Guest, on_delete: :delete_all

    has_many :images, Image, on_delete: :delete_all
    has_many :tools, Tool, on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> maybe_generate_name()
  end

  defp maybe_generate_name(changeset) do
    case get_change(changeset, :name) do
      nil ->
        changeset
        |> put_change(:name, generate_random_name())

      _ ->
        changeset
    end
  end

  defp generate_random_name do
    first = String.capitalize(Faker.Lorem.word())
    second = Integer.to_string(:rand.uniform(1000))

    "#{first} #{second}"
  end

  @doc """
  Changeset for externally updating a project.
  """
  def update_changeset(project, attrs) do
    project
    |> cast(attrs, @updatable_fields)
  end

  @doc """
  Changeset for internally updating a project.

  This changeset is used when updating a project internally, such as when
  transitioning a project from one state to another. Or when updating the
  completion percentage.

  Initially, the state is set to `:idle` and the completion percentage is set
  to `0`. When the processing actually starts, the state is set to `:processing`.

  For each intermediate step, the completion percentage is updated.

  Finally, when the processing is complete, given `completion` is equal to `100`,
  the state is set back to `:idle` and the completion percentage is reset to `0`.

  If, at any moment, the state is set to `:idle` the completion percentage is reset
  to `0`.
  """
  def state_changeset(project, attrs) do
    project
    |> cast(attrs, @internal_fields)
    |> validate_inclusion(:state, @states)
    |> maybe_validate_processing_state()
    |> maybe_reset_state()
    |> maybe_reset_completion()
    |> validate_number(:completion, greater_than_or_equal_to: 0, less_than_or_equal_to: 100)
  end

  defp maybe_validate_processing_state(changeset) do
    case get_change(changeset, :state) do
      :processing ->
        changeset
        |> validate_required(:completion)

      _ ->
        changeset
    end
  end

  defp maybe_reset_state(changeset) do
    case get_change(changeset, :completion) do
      100 ->
        changeset
        |> put_change(:state, @default_state)
        |> put_change(:completion, 0)

      _ ->
        changeset
    end
  end

  defp maybe_reset_completion(changeset) do
    case get_change(changeset, :state) do
      :idle ->
        changeset
        |> put_change(:completion, 0)

      _ ->
        changeset
    end
  end

  def can_be_processed?(project) do
    project.state == :idle && length(project.images) > 0
  end

  def states, do: @states
end
