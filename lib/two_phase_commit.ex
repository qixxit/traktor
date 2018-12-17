defmodule TwoPhaseCommit do
  @type store :: module()
  @type action :: module()
  @type ref :: any()
  @type revision :: term()
  @type state :: term()
  @type transaction :: term()
  @type transaction_ref :: term()
  @type args :: any()

  @type error_reason ::
          {:conflict, revision()}
          | {:pending, transaction_ref()}
          | term()

  @type on_error :: {:error, error_reason}

  @spec prepare(action(), state(), args(), store(), ref(), revision()) ::
          {:ok, transaction_ref()}
          | on_error()
  def prepare(action, state, args, store, ref, revision) do
    with {:ok, transaction} <- action.prepare(state, args),
         {:ok, transaction_ref} <- store.prepare(ref, revision, action, transaction) do
      {:ok, transaction_ref}
    end
  end

  @spec commit(action(), state(), transaction(), store(), ref(), transaction_ref()) ::
          {:ok, state(), revision(), result :: any()}
          | on_error()
  def commit(action, state, transaction, store, ref, transaction_ref) do
    with {:ok, new_state, result} <- action.commit(state, transaction),
         {:ok, revison} <- store.commit(ref, transaction_ref, new_state) do
      {:ok, new_state, revison, result}
    end
  end
end
