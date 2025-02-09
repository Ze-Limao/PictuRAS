defmodule ProjectsApiWeb.ProjectControllerTest do
  use ProjectsApiWeb.ConnCase

  import ProjectsApi.ProjectsFixtures

  @create_attrs %{
    name: "Foo Bar",
    state: :idle,
    completion: 42,
    user_id: "7488a646-e31f-11e4-aace-600308960662"
  }

  @update_attrs %{
    name: "Bar Foo",
    state: :processing,
    completion: 43,
    user_id: "7488a646-e31f-11e4-aace-600308960668"
  }

  @token "eyJhbGciOiJSUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJ1c2VycyIsImV4cCI6MTczOTA2MDE2NSwiaWF0IjoxNzM2NjQwOTY1LCJpc3MiOiJ1c2VycyIsImp0aSI6IjEzMDliYTcyLWQ3YTctNGM2Ni05MDRkLWYzZjYzYTU1OTRkYSIsIm5iZiI6MTczNjY0MDk2NCwic3ViIjoiYzEwMzdlZjUtZGMzNC00YzA0LTgxNTUtYWMyYzk1ZWIyZDBjIiwidHlwIjoiYWNjZXNzIn0.IoFW0ADRPBI_ivzeiR3h8Qks2kpCtDSZJy01879MempEv5HINZL0MmRGRqkxk4OIJCdnGeT2acyq0OEgavrqE5LE4QKmrLS7_6_Qzm1_fCrC9RYmqA762VgvODXCw_ErgX5h0zLUk7g5T3rKEI5jQLdja7wa0Asm-vdhAfxJy12a_MbCd_CHYTc4uNQSX8ijmA91Svw2Oc3dCrbUYdgw0Ej_IgoUEf6--AbtOlOFx176YkJ4PQiGWyRMcUVfj8IOrwMh1KetSjK7uex56s1hXZkOfcLgXKUgbRSOC2MMeCg1a97pCfsThVM1Ir1AUpNeNR-iQXwTlf-UuxWJMlhvGw"

  setup %{conn: conn} do
    user_id = Ecto.UUID.generate()
    {:ok, conn: put_req_header(conn, "accept", "application/json"), user_id: user_id}
  end

  describe "index" do
    test "lists all projects of user", %{conn: conn, user_id: user_id} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{@token}")
        |> get(~p"/api/v1/users/#{user_id}/projects")

      assert json_response(conn, 200)["data"] == []
    end

    test "lists all projects of user when he has some", %{conn: conn, user_id: user_id} do
      project = project_fixture(user_id: user_id)
      project_id = project.id

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{@token}")
        |> get(~p"/api/v1/users/#{user_id}/projects")

      assert json_response(conn, 200)["data"] == [
               %{"id" => project_id, "completion" => 0, "name" => "Foo Bar", "state" => "idle"}
             ]
    end
  end

  describe "create" do
    test "creates a project", %{conn: conn, user_id: user_id} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{@token}")
        |> post(~p"/api/v1/users/#{user_id}/projects", project: @create_attrs)

      assert json_response(conn, 201)["data"]["id"]
    end

    test "creates a project with default state and completion equal to 0, even if other state is passed",
         %{conn: conn, user_id: user_id} do
      create_attrs = @create_attrs |> Map.put(:state, :processing)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{@token}")
        |> post(~p"/api/v1/users/#{user_id}/projects", project: create_attrs)

      assert json_response(conn, 201)["data"]["state"] == "idle"
      assert json_response(conn, 201)["data"]["completion"] == 0
    end
  end

  describe "update" do
    test "updates a project", %{conn: conn, user_id: user_id} do
      project = project_fixture(user_id: user_id)
      project_id = project.id

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{@token}")
        |> put(~p"/api/v1/users/#{user_id}/projects/#{project_id}", project: @update_attrs)

      assert json_response(conn, 200)["data"]["name"] == "Bar Foo"
    end

    test "another user can't update a project", %{conn: conn, user_id: user_id} do
      project = project_fixture()
      project_id = project.id

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{@token}")
        |> put(~p"/api/v1/users/#{user_id}/projects/#{project_id}", project: @update_attrs)

      assert json_response(conn, 404)["errors"] != []
    end

    test "does not allow to update a state (and/or completion percentage)", %{
      conn: conn,
      user_id: user_id
    } do
      project = project_fixture(user_id: user_id)
      project_id = project.id

      update_attrs = %{state: :processing, completion: 43}

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{@token}")
        |> put(~p"/api/v1/users/#{user_id}/projects/#{project_id}", project: update_attrs)

      assert json_response(conn, 200)["data"]["state"] != "processing"
      assert json_response(conn, 200)["data"]["completion"] != 43
    end
  end

  describe "delete" do
    test "deletes a project", %{conn: conn, user_id: user_id} do
      project = project_fixture(user_id: user_id)
      project_id = project.id

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{@token}")
        |> delete(~p"/api/v1/users/#{user_id}/projects/#{project_id}")

      assert conn.status == 204
    end

    test "another user can't delete a project", %{conn: conn, user_id: user_id} do
      project = project_fixture()
      project_id = project.id

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{@token}")
        |> delete(~p"/api/v1/users/#{user_id}/projects/#{project_id}")

      assert json_response(conn, 404)["errors"] != []
    end
  end
end
