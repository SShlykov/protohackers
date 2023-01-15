defmodule EchoServerTest do
  @moduledoc false
  require Logger
  use ExUnit.Case, async: true

  def init_socket() do
    port = Application.get_env(:protohackers, :echo_port)
    opts = [mode: :binary, active: false]
    :gen_tcp.connect(~c"localhost", port, opts)
  end

  def send_and_recv(socket, data) do
    :gen_tcp.send(socket, data)
    Logger.info("sended: " <> inspect(data))
    {:ok, data} = :gen_tcp.recv(socket, 0, 5000)
    data
  end

  test "echoes binary messages back" do
    {:ok, socket} = init_socket()
    assert :gen_tcp.send(socket, "foo") == :ok
    assert :gen_tcp.send(socket, "bar") == :ok

    :gen_tcp.shutdown(socket, :write)

    assert :gen_tcp.recv(socket, 0, 5000) == {:ok, "foobar"}
  end

  test "echo server closed session on buffer overflow" do
    {:ok, socket} = :gen_tcp.connect(~c"localhost", Application.get_env(:protohackers, :echo_port), [mode: :binary, active: :false])

    assert :gen_tcp.send(socket, String.duplicate("a", 102_400 + 1)) == :ok
    assert :gen_tcp.recv(socket, 0, :timer.seconds(10))  == {:error, :closed}
  end

  test "handle multiple connections" do
    tasks =
      for _ <- 1..4 do
        Task.async(fn ->
          {:ok, socket} = init_socket()
          assert :gen_tcp.send(socket, "foo") == :ok
          assert :gen_tcp.send(socket, "bar") == :ok

          :gen_tcp.shutdown(socket, :write)

          assert :gen_tcp.recv(socket, 0, 5000) == {:ok, "foobar"}
        end)
      end

    Task.await_many(tasks, 7000)
  end
end
