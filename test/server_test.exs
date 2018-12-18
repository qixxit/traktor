defmodule TwoPhaseCommit.ServerTest do
  use ExUnit.Case

  alias TwoPhaseCommit.Store.InMemory, as: Store
  alias TwoPhaseCommit.Action.NoOp, as: Action
  alias TwoPhaseCommit.Server

  test "call/3" do
    assert {:ok, ref} = Store.start_link(%{})
    assert {:ok, server} = Server.start_link(ref, Store)
    assert [:foo, :bar] = Server.call(server, Action, [:foo, :bar])
  end

  test "cast/3" do
    assert {:ok, ref} = Store.start_link(%{})
    assert {:ok, server} = Server.start_link(ref, Store)
    assert :ok = Server.cast(server, Action, [:foo, :bar])
  end
end
