defmodule Protohackers.Tcp do
  @moduledoc false
  use GenServer
  require Logger

  defstruct [:socket, :listener, :port]

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: Keyword.get(opts, :name))

  @impl true
  def init(opts) do
    port           = Keyword.get(opts, :port)
    server_options = [:binary, ifaddr: {0, 0, 0, 0}, active: false, reuseaddr: true, exit_on_close: false]

    case :gen_tcp.listen(port, server_options) do
      {:ok, socket} ->
        state = struct(%__MODULE__{socket: socket}, opts)
        {:ok, state, {:continue, :accept}}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  @impl true
  def handle_continue(:accept, state) do
    case :gen_tcp.accept(state.socket) do
      {:ok, socket} ->
        {:ok, pid} = start_communication(Map.get(state, :listener), socket)
        :gen_tcp.controlling_process(socket, pid)
        {:noreply, state, {:continue, :accept}}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  defp start_communication(listener, client_socket),
    do: Task.Supervisor.start_child(listener, fn -> apply(listener, :handle_message, [client_socket]) end)
end
