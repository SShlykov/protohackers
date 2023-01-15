defmodule Protohackers.EchoServer.Supervisor do
  @moduledoc false
  use Supervisor
  require Logger
  alias Protohackers.EchoServer.Listener, as: EchoServer
  @evt_base ~w(protohackers echo_server supervisor)a

  def start_link(args), do: Supervisor.start_link(__MODULE__, [{:name, __MODULE__} | args])

  @impl Supervisor
  def init(_args) do
    children  = [
                  {Task.Supervisor,  name: EchoServer,     max_children: max_clients()          },
                  {Protohackers.Tcp, listener: EchoServer, port: echo_port(), name: :echo_server}
                ]
    opts      = [strategy: :one_for_one]

    Logger.info("Started Echo Server at #{echo_port()} port")
    :telemetry.span(@evt_base, %{children: children, opts: opts}, fn -> {Supervisor.init(children, opts), %{}} end)
  end

  def max_clients(), do: Application.get_env(:protohackers, :max_clients, 100)
  def echo_port(),   do: Application.get_env(:protohackers, :echo_port)
  def events(),      do: Protohackers.Helpers.events(@evt_base, ~w(start stop exception)a)
end
