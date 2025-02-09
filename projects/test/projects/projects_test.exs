defmodule ProjectsApi.ProjectsTest do
  use ProjectsApi.DataCase

  alias ProjectsApi.Projects

  describe "projects" do
    alias ProjectsApi.Projects.Project

    import ProjectsApi.ProjectsFixtures

    @invalid_attrs %{name: nil, state: nil, completion: nil, user_id: nil}

    test "list_projects/1 returns all projects from a user" do
      project = project_fixture()
      other_user_id = "7488a646-e31f-11e4-aace-600308960668"
      assert Projects.list_projects(project.user_id) == [project]
      assert Projects.list_projects(other_user_id) == []
    end

    test "get_project!/1 returns the project with given id" do
      project = project_fixture()
      assert Projects.get_project!(project.id) == project
    end

    test "create_project/1 with valid data creates a project" do
      valid_attrs = %{
        name: "Foo Bar",
        user_id: "7488a646-e31f-11e4-aace-600308960662"
      }

      assert {:ok, %Project{} = project} = Projects.create_project(valid_attrs)
      assert project.name == "Foo Bar"
      assert project.user_id == "7488a646-e31f-11e4-aace-600308960662"
    end

    test "create_project/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Projects.create_project(@invalid_attrs)
    end

    test "create_project/1 with given state and/or completion, does not affect its default value" do
      valid_attrs = %{
        name: "Foo Bar",
        state: "processing",
        completion: 30,
        user_id: "7488a646-e31f-11e4-aace-600308960662"
      }

      assert {:ok, %Project{} = project} = Projects.create_project(valid_attrs)
      assert project.state == :idle
      assert project.completion == 0
    end

    test "update_project/2 with valid data updates the project" do
      project = project_fixture()

      update_attrs = %{name: "Bar Foo"}

      assert {:ok, %Project{} = project} = Projects.update_project(project, update_attrs)
      assert project.name == "Bar Foo"
    end

    test "update_project/2 with given user_id does not affect the project data" do
      project = project_fixture()

      update_attrs = %{user_id: "7488a646-e31f-11e4-aace-600308960662"}

      assert {:ok, %Project{} = project} = Projects.update_project(project, update_attrs)
      assert project.user_id == project.user_id
    end

    test "update_project_state/2 updates the project state and completion" do
      project = project_fixture()

      update_attrs = %{state: :processing, completion: 30}

      assert {:ok, %Project{} = project} = Projects.update_project_state(project, update_attrs)
      assert project.state == :processing
      assert project.completion == 30
    end

    test "update_project_state/2 with completion equal to 100 sets the project state back to idle and resets completion" do
      project = project_fixture(state: :processing)

      update_attrs = %{completion: 100}

      assert {:ok, %Project{} = project} = Projects.update_project_state(project, update_attrs)
      assert project.state == :idle
      assert project.completion == 0
    end

    test "update_project_state/2 with a completion value outside boundaries returns error changeset" do
      project = project_fixture()

      update_attrs = %{completion: -1}
      assert {:error, %Ecto.Changeset{}} = Projects.update_project_state(project, update_attrs)

      update_attrs = %{completion: 101}
      assert {:error, %Ecto.Changeset{}} = Projects.update_project_state(project, update_attrs)
    end

    test "update_project_state/2 by setting the state to idle resets the completion" do
      project = project_fixture(state: :processing, completion: 30)

      update_attrs = %{state: :idle}

      assert {:ok, %Project{} = project} = Projects.update_project_state(project, update_attrs)
      assert project.state == :idle
      assert project.completion == 0
    end

    test "delete_project/1 deletes the project" do
      project = project_fixture()
      assert {:ok, %Project{}} = Projects.delete_project(project)
      assert_raise Ecto.NoResultsError, fn -> Projects.get_project!(project.id) end
    end

    test "change_project/1 returns a project changeset" do
      project = project_fixture()
      assert %Ecto.Changeset{} = Projects.change_project(project)
    end
  end
end
