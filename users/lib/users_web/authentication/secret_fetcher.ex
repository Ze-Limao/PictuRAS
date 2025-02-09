defmodule UsersApiWeb.Authentication.SecretFetcher do
  @moduledoc """
  Fetches signing secrets from the environment. Verification
  is done using the public key, but at the gateway level.

  These secrets will be used by `guardian` to sign and verify JWT tokens.

  ## Instructions for generating secrets

  Inside the `secrets` directory, run the following commands:

  ```bash
  # Generate the private key
  openssl genrsa -aes256 -out private_key.pem 2048

  # Derive the public key from the private key
  openssl rsa -pubout -in private_key.pem -out public_key.pem
  ```

  Put your password in a file named `password` under the `secrets` directory.
  """
  use Guardian.Token.Jwt.SecretFetcher

  @behaviour Guardian.Token.Jwt.SecretFetcher

  @path Application.compile_env(:users, :secrets_folder) || "secrets"

  @impl true
  def fetch_signing_secret(_module, _opts) do
    password = File.read!(@path <> "/password")
    content = File.read!(@path <> "/private_key.pem")
    secret = JOSE.JWK.from_pem(password, content)
    {:ok, secret}
  end
end
