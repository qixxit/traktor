defmodule Traktor.Action.NoOp do
  @behaviour Traktor.Action

  @impl Traktor.Action
  def prepare(_state, args) do
    {:ok, args}
  end

  @impl Traktor.Action
  def commit(state, transaction) do
    {:ok, state, transaction}
  end
end
