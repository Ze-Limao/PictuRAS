defmodule UsersApiWeb.UserControllerTest do
  use UsersApiWeb.ConnCase

  import UsersApi.AccountsFixtures
  import UsersApiWeb.Authentication.Guardian

  @create_attrs %{
    name: "Foo Bar",
    email: "foo@example.com",
    password: "password1234"
  }

  @invalid_attrs %{name: nil, email: nil, password: 1234}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "register" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/register", user: @create_attrs)

      assert %{
               "name" => "Foo Bar",
               "email" => "foo@example.com"
             } = json_response(conn, 201)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/register", user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "login" do
    setup [:create_user]

    test "renders user when data is valid", %{conn: conn, user: user} do
      conn =
        post(conn, ~p"/api/v1/login", %{
          email: user.email,
          password: "password1234"
        })

      name = user.name
      email = user.email

      assert %{
               "name" => ^name,
               "email" => ^email
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, ~p"/api/v1/login", %{
          email: "foo@not_found.com",
          password: "password1234"
        })

      assert json_response(conn, 401)["errors"] != %{}
    end
  end

  describe "me" do
    setup [:create_user]

    test "renders user when data is valid", %{conn: conn, user: user} do
      {:ok, token, _claims} = encode_and_sign(user, %{}, token_type: :access)

      conn =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> get(~p"/api/v1/me")

      name = user.name
      email = user.email

      assert %{
               "name" => ^name,
               "email" => ^email
             } = json_response(conn, 200)["data"]
    end
  end

  defp create_user(_) do
    user = user_fixture()
    %{user: user}
  end
end
