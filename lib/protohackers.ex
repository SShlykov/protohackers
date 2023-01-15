defmodule Protohackers do
  @moduledoc """
  Documentation for `Protohackers`.
  """
  use Application
  alias Protohackers.Helpers
  alias Protohackers.EchoServer.Supervisor, as: EchoServer
  @evt_base ~w(protohackers boot)a

  def start(_type, _args) do
    :ok = Helpers.attach_events([EchoServer, Protohackers])

    children = [EchoServer]
    opts     = [strategy: :one_for_one, name: SmokeTest.Supervisor]

    :telemetry.span(@evt_base, %{children: children, opts: opts}, fn -> {Supervisor.start_link(children, opts), %{}} end)
  end

  def events(), do: Protohackers.Helpers.events(@evt_base, ~w(start stop exception)a)
end
