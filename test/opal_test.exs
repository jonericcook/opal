defmodule OpalTest do
  use ExUnit.Case
  doctest Opal

  test "greets the world" do
    assert Opal.hello() == :world
  end
end
