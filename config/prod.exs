import Config

config :protohackers,
  echo_port:   System.get_env("PH_ECHO_PORT", "2001") |> String.to_integer(),
  max_clients: System.get_env("PH_MAX_CLIENTS", "100") |> String.to_integer()
