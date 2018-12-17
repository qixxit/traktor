defmodule TwoPhaseCommit.Action.NoOp do
  @behaviour TwoPhaseCommit.Action

  @impl TwoPhaseCommit.Action
  def prepare(_state, args) do
    {:ok, args}
  end

  @impl TwoPhaseCommit.Action
  def commit(state, transaction) do
    {:ok, state, transaction}
  end
end
