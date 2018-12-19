defmodule TraktorTest do
  use ExUnit.Case

  alias Traktor.Store.InMemory, as: Store
  alias Traktor.Action.NoOp, as: Action

  test "prepare and commit" do
    assert {:ok, ref} = Store.start_link(%{})
    assert {:ok, revision, state} = Store.get(ref)

    assert {:ok, transaction, transaction_ref} =
             Traktor.prepare(Action, state, [:foo, :bar], Store, ref, revision)

    assert {:ok, new_state, new_revision, result} =
             Traktor.commit(Action, state, transaction, Store, ref, transaction_ref)

    assert result == [:foo, :bar]
    assert {:ok, new_revision, new_state} = Store.get(ref)
  end

  test "apply" do
    assert {:ok, ref} = Store.start_link(%{})
    assert {:ok, revision, state} = Store.get(ref)

    assert {:ok, new_state, new_revision, result} =
             Traktor.apply(Action, state, [:foo, :bar], Store, ref, revision)

    assert result == [:foo, :bar]
    assert {:ok, new_revision, new_state} = Store.get(ref)
  end
end
