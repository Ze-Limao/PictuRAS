defmodule ProjectsApiWeb.Router do
  use ProjectsApiWeb, :router

  alias ProjectsApiWeb.Plugs

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :ensure_self do
    plug Plugs.EnsureSelf
  end

  pipeline :ensure_project_owner do
    plug Plugs.VerifyProjectOwnership, :owner
  end

  pipeline :ensure_project_guest do
    plug Plugs.VerifyProjectOwnership, :guest
  end

  scope "/api", ProjectsApiWeb do
    pipe_through :api

    get "/health", HealthController, :health

    scope "/v1" do
      pipe_through [:ensure_self]
      post "/users/:user_id/projects", ProjectController, :create
      get "/users/:user_id/tools", ToolController, :index

      pipe_through [:ensure_project_guest]

      scope "/users/:user_id/projects" do
        get "/", ProjectController, :index
        get "/:id", ProjectController, :show

        get "/:id/:image_id", ImageController, :download
      end

      pipe_through [:ensure_project_owner]

      scope "/users/:user_id/projects/:id" do
        put "/", ProjectController, :update
        delete "/", ProjectController, :delete

        post "/invite", InviteController, :invite
        put "/revoke", InviteController, :revoke

        post "/upload", ImageController, :upload
        delete "/:image_id", ImageController, :delete

        post "/process", ProcessController, :process
      end
    end
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:projects, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: ProjectsApiWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
