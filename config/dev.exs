import Config

# Configure your database
config :friendly, Friendly.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "friendly_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :friendly, FriendlyWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "0fg6tT9dAPfHALzkVcNICEvn5GcJwXv3si5TMWbSR+gKJpsbwLIn24toXrVW9uA7",
  watchers: []

config :friendly, dev_routes: true

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime
