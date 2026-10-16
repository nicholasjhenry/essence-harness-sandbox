defmodule EssenceHarnessSandboxTest do
  use ExUnit.Case
  doctest EssenceHarnessSandbox

  test "greets the world" do
    assert EssenceHarnessSandbox.hello() == :world
  end
end
