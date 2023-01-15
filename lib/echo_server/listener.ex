defmodule Protohackers.EchoServer.Listener do
  @moduledoc false
  require Logger

  def handle_message(socket) do
    case receive_buffer(socket, _buffer = "") do
      {:ok, data}      -> :ok = :gen_tcp.send(socket, data)
      {:error, reason} -> Logger.error("Failed to receive data: #{inspect(reason)}")
    end

    :gen_tcp.close(socket)
  end

  @limit _100_kb = 1024 * 100

  def receive_buffer(socket, buffer) do
    case :gen_tcp.recv(socket, 0, :timer.seconds(5)) do
      {:ok, data} when byte_size(buffer <> data) > @limit  -> {:error, :buffer_overflow}
      {:ok, data}                                          -> receive_buffer(socket, buffer <> data)
      {:error, :closed}                                    -> {:ok, buffer}
      {:error, reason}                                     -> {:error, reason}
    end
  end
end
