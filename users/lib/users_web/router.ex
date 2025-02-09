defmodule UsersApiWeb.Router do
  use UsersApiWeb, :router

  alias UsersApiWeb.Plugs

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :current_user do
    plug :fetch_session
    plug Plugs.SetCurrentUser
  end

  scope "/api", UsersApiWeb do
    pipe_through :api

    scope "/v1" do
      post "/register", UserController, :register
      post "/login", UserController, :login

      pipe_through :current_user
      get "/me", UserController, :me
      put "/me", UserController, :update
    end
  end

  scope "/internal", UsersApiWeb do
    pipe_through :api

    get "/users", InternalUserController, :show
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:users, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: UsersApiWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
