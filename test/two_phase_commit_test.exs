defmodule TwoPhaseCommitTest do
  use ExUnit.Case
  doctest TwoPhaseCommit

  test "greets the world" do
    assert TwoPhaseCommit.hello() == :world
  end
end
