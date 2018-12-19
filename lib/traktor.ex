defmodule Traktor do
  @moduledoc """
  `Traktor` is a library to execute actions in a traceable manner by applying a two-phase-commit pattern.

  It is mainly defined by two behaviours:
  - `Traktor.Action` for the business logic;
  - `Traktor.Store` for the persistance layer.

  ### Entity
  An action or a group of actions can be applied to an entity. The action is a behaviour that transforms an entity from one version to another.
  Eg. **booking** and **payment** actions are applied to the **Checkout** entity.
  """

  @typedoc "Module implementing the `Traktor.Store` behaviour. An in memory store is provided with the package."
  @type store :: module()

  @typedoc "Module implementing the `Traktor.Action` behaviour."
  @type action :: module()

  @typedoc "Unique reference of an entity."
  @type ref :: any()

  @typedoc "The revision of the state of an entity."
  @type revision :: term()

  @typedoc "The state of an entity at a specific revision."
  @type state :: term()

  @typedoc "A transaction contains all the information required to commit an action."
  @type transaction :: term()

  @typedoc "Unique reference of a transaction."
  @type transaction_ref :: term()

  @typedoc "Specific arguments required to apply an action to an entity."
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
         {:ok, revision} <- store.commit(ref, transaction_ref, new_state) do
      {:ok, new_state, revision, result}
    end
  end

  @doc "Runs both phases of the two phase commit: `prepare/6` and `commit/6`."
  @spec apply(action(), state(), args(), store(), ref(), revision()) ::
          {:ok, state(), revision(), result :: any()}
          | on_error()
  def apply(action, state, args, store, ref, revision) do
    with {:ok, transaction, transaction_ref} <-
           prepare(action, state, args, store, ref, revision),
         {:ok, new_state, revision, result} <-
           commit(action, state, transaction, store, ref, transaction_ref) do
      {:ok, new_state, revision, result}
    end
  end
end
