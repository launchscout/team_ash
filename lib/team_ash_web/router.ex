defmodule TeamAshWeb.Router do
  use TeamAshWeb, :router

  use AshAuthentication.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TeamAshWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TeamAshWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/test_form", PageController, :test_form

    live "/foo_form", FooForm

    ash_authentication_live_session :authentication_required,
      on_mount: {TeamAshWeb.LiveAuth, :live_user_required} do
      live "/engagements", EngagementLive.Index, :index
      live "/engagements/new", EngagementLive.Index, :new
      live "/engagements/:id", EngagementLive.Show, :show
      live "/engagements/:id/show/edit", EngagementLive.Show, :edit

      live "/clients", ClientLive.Index, :index
      live "/clients/new", ClientLive.Index, :new
      live "/clients/:id/edit", ClientLive.Index, :edit

      live "/clients/:id", ClientLive.Show, :show
      live "/clients/:id/show/edit", ClientLive.Show, :edit
    end

    sign_in_route(register_path: "/register", reset_path: "/reset")
    sign_out_route AuthController
    auth_routes_for TeamAsh.Accounts.User, to: AuthController
    reset_route []
  end

  # Other scopes may use custom stacks.
  # scope "/api", TeamAshWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:team_ash, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TeamAshWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
