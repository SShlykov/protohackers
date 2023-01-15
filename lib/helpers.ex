defmodule Protohackers.Helpers do
  @moduledoc """
  Helpers funcs
  """
  @type context() :: list(atom())
  @type events()  :: list(atom())

  @doc """
  makes event list for telemetry

  f.e.
      iex> Protohackers.Helpers.events(~w(myapp boot)a, ~w(start stop)a)
      [~w(myapp boot start)a, ~w(myapp boot stop)a]
  """
  @spec events(context(), events()) :: list(list(atom()))
  def events(context, event_list \\ ~w()a), do: Enum.map(event_list, & context ++ [&1])

  @doc """
  attaching modules events via telemetry module
  """
  @spec attach_events(list(module())) :: :ok | {:error, :already_exists}
  def attach_events(evts) do
    evts = Enum.reduce(evts, [], & &2 ++ get_events(&1))

    :telemetry.attach_many(__MODULE__, evts, &Protohackers.TelemetryHandler.handle_event/4, [])
  end

  @doc """
  gets event list for supervisor to iniciate
  """
  def get_events(module) do
    apply(module, :events, [])
  rescue
    _e -> throw("Module #{module} has no events function or invalid")
  end
end
