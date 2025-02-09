defmodule ProjectsApi.ProjectsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ProjectsApi.Projects` context.
  """

  alias ProjectsApi.Projects

  @doc """
  Generate a project.
  """
  def project_fixture(attrs \\ %{}) do
    {:ok, project} =
      attrs
      |> Enum.into(%{
        name: "Foo Bar",
        state: :idle,
        completion: 42,
        user_id: "7488a646-e31f-11e4-aace-600308960662"
      })
      |> Projects.create_project()

    project
  end
end
