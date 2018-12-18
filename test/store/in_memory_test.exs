defmodule TwoPhaseCommit.Store.InMemoryTest do
  use ExUnit.Case

  alias TwoPhaseCommit.Store.InMemory, as: Store

  defmodule Action do
  end

  test "get, prepare, and commit" do
    assert {:ok, ref} = Store.start_link("Initial State")
    assert {:ok, revision, "Initial State"} = Store.get(ref)
    assert {:ok, transaction_ref} = Store.prepare(ref, revision, Action, "Transaction Data")

    assert {:pending, "Initial State", Action, "Transaction Data", transaction_ref} =
             Store.get(ref)

    assert {:ok, new_revision} = Store.commit(ref, transaction_ref, "Updated State")
    assert {:ok, new_revision, "Updated State"} = Store.get(ref)
  end

  test "fail with conflict on wrong revision" do
    assert {:ok, ref} = Store.start_link("Initial State")
    assert {:ok, revision, "Initial State"} = Store.get(ref)
    assert revision != 99999
    assert {:error, :conflict} = Store.prepare(ref, 99999, Action, "Transaction Data")
  end

  test "fail with conflict on pending transaction" do
    assert {:ok, ref} = Store.start_link("Initial State")
    assert {:ok, revision, "Initial State"} = Store.get(ref)
    assert {:ok, _transaction_ref} = Store.prepare(ref, revision, Action, "Transaction Data")

    assert {:error, :conflict} = Store.prepare(ref, revision, Action, "Other Transaction Data")
  end

  test "fail with conflict on wrong transaction_ref" do
    assert {:ok, ref} = Store.start_link("Initial State")
    assert {:ok, revision, "Initial State"} = Store.get(ref)
    assert {:ok, transaction_ref} = Store.prepare(ref, revision, Action, "Transaction Data")
    assert transaction_ref != 99999
    assert {:error, :conflict} = Store.commit(ref, 99999, "Updated State")
  end

  test "fail with conflict on missing transaction" do
    assert {:ok, ref} = Store.start_link("Initial State")
    assert {:ok, revision, "Initial State"} = Store.get(ref)
    assert {:error, :conflict} = Store.commit(ref, 99999, "Updated State")
  end
end
