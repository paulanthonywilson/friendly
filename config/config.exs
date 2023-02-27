import Config

config :friendly, ecto_repos: [Friendly.Repo]

# Configures the endpoint
config :friendly, FriendlyWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [json: FriendlyWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Friendly.PubSub,
  live_view: [signing_salt: "x0mTv3h8"]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
