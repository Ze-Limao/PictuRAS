defmodule ProjectsApiWeb.InternalRequester do
  @moduledoc """
  This module is responsible for making requests to internal services.
  """
  alias Req.{Request, Response}

  @users_microservice Application.compile_env(:projects, :microservices)[:users] ||
                        "http://localhost:4001"

  @doc """
  Check if a user exists by email.

  It requests the users microservice.
  """
  def user_exists?(email) do
    url = put_params(@users_microservice <> "/internal/users", %{"email" => email})
    req = build_request(:get, url)

    case Request.run_request(req) do
      {_, %Response{status: 200} = response} ->
        {:ok, response.body}

      {_, %Response{status: 404}} ->
        {:error, :not_found}

      {_, _exception} ->
        {:error, :internal_server_error}
    end
  end

  defp build_request(method, url) do
    Req.new(method: method, url: url)
    |> Request.put_new_header("Content-Type", "application/json")
  end

  defp put_params(url, params) do
    encoded = URI.encode_query(params)
    url <> "?" <> encoded
  end
end
