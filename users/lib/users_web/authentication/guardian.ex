defmodule UsersApiWeb.Authentication.Guardian do
  @moduledoc """
  Responsible for user authentication and authorization interactions
  regarding `guardian` library.
  """
  use Guardian, otp_app: :users

  alias UsersApi.Accounts
  alias UsersApi.Accounts.User

  def subject_for_token(%User{} = user, _claims) do
    {:ok, to_string(user.id)}
  end

  def resource_from_claims(%{"sub" => id}) do
    case Accounts.get_user(id) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end
end
