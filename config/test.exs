import Config

config :friendly, Friendly.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "friendly_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :friendly, FriendlyWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "vNrl2/+bFZU3Oj+PEInnlJM6+k20yyF2iaB/Zh9UI5KLKY+rlMQg2U7qovDBzKtG",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
