import Config

config :logger, level: :info

# Run against the dev database _as if in production_, to see errors etc...
#

# config :friendly, Friendly.Repo,
#   username: "postgres",
#   password: "postgres",
#   hostname: "localhost",
#   database: "friendly_dev",
#   stacktrace: true,
#   show_sensitive_data_on_connection_error: true,
#   pool_size: 10

# config :friendly, FriendlyWeb.Endpoint,
#   http: [ip: {127, 0, 0, 1}, port: 4000],
#   check_origin: false,
#   code_reloader: false,
#   debug_errors: false,
#   secret_key_base: "0fg6tT9dAPfHALzkVcNICEvn5GcJwXv3si5TMWbSR+gKJpsbwLIn24toXrVW9uA7",
#   watchers: []
