# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :defeat_the_loan,
  ecto_repos: [DefeatTheLoan.Repo]

# Configures the endpoint
config :defeat_the_loan, DefeatTheLoan.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "hsU19ClAsynp47nlqgtubtRUa+iJVTrMYlRxMbCfSCNIns9EXsmqHMOpgC5Ub7qS",
  render_errors: [view: DefeatTheLoan.ErrorView, accepts: ~w(html json)],
  pubsub: [name: DefeatTheLoan.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
