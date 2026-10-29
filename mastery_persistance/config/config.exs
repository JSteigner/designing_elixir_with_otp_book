use Mix.Config

config :mastery_persistance, ecto_repos: [MasteryPersistance.Repo]

config :logger, level: :info

import_config "#{Mix.env().exs}"
