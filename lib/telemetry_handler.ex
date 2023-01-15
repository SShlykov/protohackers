defmodule Protohackers.TelemetryHandler do
  @moduledoc """
  Telemetry handler
  """
  require Logger

  def handle_event(_evt, _measurement, %{children: _childs, opts: _opts}, _config) do
    # Logger.info("Application boot begins. Children: #{inspect(childs)}. Opts: #{inspect(opts)}")
    :ok
  end

  def handle_event(~w[protohackers boot stop]a, %{duration: duration}, _metadata, _config) do
    Logger.info("Application booted in #{to_ms(duration)}ms")
  end

  def handle_event(~w[protohackers echo_server supervisor stop]a, %{duration: duration}, _metadata, _config) do
    Logger.info("EchoServer booted in #{to_ms(duration)}ms")
  end

  def handle_event(event, measurement, metadata, config) do
    params = %{measurement: measurement, metadata: metadata, config: config}

    Logger.warn("Unknown event: [#{inspect(event)}]. Event params: #{inspect(params)}")
  end

  def to_ms(time), do: System.convert_time_unit(time, :native, :millisecond)
end
