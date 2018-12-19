defmodule TwoPhaseCommit do
  @moduledoc """
  `TwoPhaseCommit` is a library to execute actions in a traceable manner by applying a two-phase-commit pattern:
  - for the business logic of the action, and
  - for the persistance layer.

  It is mainly defined by tho behaviours:
  - `TwoPhaseCommit.Action` for the business logic, and
  - `TwoPhaseCommit.Store` for the persistance layer.

  ### Entity
  An action or a group of actions can be applied to an entity. The action is a behaviour that transforms an entity from one version to another.
  Eg. **booking** and **payment** actions are applied to the **Checkout** entity.

  """

  @typedoc "Module implementing the `TwoPhaseCommit.Store` behaviour."
  @type store :: module()
  @typedoc "Module implementing the `TwoPhaseCommit.Action` behaviour. An in memory store is provided with the package."
  @type action :: module()
  @typedoc "Unique reference for the entity. "
  @type ref :: any()
  @typedoc "The entity revision."
  @type revision :: term()
  @typedoc "The state of an entity at a specific revision."
  @type state :: term()
  @typedoc "A transaction contains all the information required to commit an action."
  @type transaction :: term()
  @typedoc "Unique reference for a transaction."
  @type transaction_ref :: term()
  @typedoc "Specific arguments required to apply the action to an entity."
  @type args :: any()

  @type error_reason ::
          {:conflict, revision()}
          | {:pending, transaction_ref()}
          | term()

  @type on_error :: {:error, error_reason}

  @doc "Prepares the execution of the businses logic and persists it."
  @spec prepare(action(), state(), args(), store(), ref(), revision()) ::
          {:ok, transaction(), transaction_ref()}
          | on_error()
  def prepare(action, state, args, store, ref, revision) do
    with {:ok, transaction} <- action.prepare(state, args),
         {:ok, transaction_ref} <- store.prepare(ref, revision, action, transaction) do
      {:ok, transaction, transaction_ref}
    end
  end

  @doc "Executes the business logic and persists the result."
  @spec commit(action(), state(), transaction(), store(), ref(), transaction_ref()) ::
          {:ok, state(), revision(), result :: any()}
          | on_error()
  def commit(action, state, transaction, store, ref, transaction_ref) do
    with {:ok, new_state, result} <- action.commit(state, transaction),
         {:ok, revison} <- store.commit(ref, transaction_ref, new_state) do
      {:ok, new_state, revison, result}
    end
  end

  @doc "Runs both phases of the two phase commit: `prepare/6` and `commit/6`."
  @spec apply(action(), state(), args(), store(), ref(), revision()) ::
          {:ok, state(), revision(), result :: any()}
          | on_error()
  def apply(action, state, args, store, ref, revision) do
    with {:ok, transaction, transaction_ref} <-
           prepare(action, state, args, store, ref, revision),
         {:ok, new_state, revison, result} <-
           commit(action, state, transaction, store, ref, transaction_ref) do
      {:ok, new_state, revison, result}
    end
  end
end
