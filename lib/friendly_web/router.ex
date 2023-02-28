defmodule FriendlyWeb.Router do
  use FriendlyWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FriendlyWeb do
    pipe_through :api
    get "/", ScoresController, :qualifying_two_users
  end

  if Application.compile_env(:friendly, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: FriendlyWeb.Telemetry
    end
  end
end
