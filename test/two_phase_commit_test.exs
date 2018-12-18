defmodule TwoPhaseCommitTest do
  use ExUnit.Case

  alias TwoPhaseCommit.Store.InMemory, as: Store
  alias TwoPhaseCommit.Action.NoOp, as: Action

  test "prepare and commit" do
    assert {:ok, ref} = Store.start_link(%{})
    assert {:ok, revision, state} = Store.get(ref)

    assert {:ok, transaction, transaction_ref} =
             TwoPhaseCommit.prepare(Action, state, [:foo, :bar], Store, ref, revision)

    assert {:ok, new_state, new_revision, result} =
             TwoPhaseCommit.commit(Action, state, transaction, Store, ref, transaction_ref)

    assert result == [:foo, :bar]
    assert {:ok, new_revision, new_state} = Store.get(ref)
  end
end
