defmodule ProtohackersDockTest do
  @moduledoc false
  use ExUnit.Case

  doctest Protohackers
  doctest Protohackers.Helpers

  test "tests" do
    assert :hello == :hello
  end
end
