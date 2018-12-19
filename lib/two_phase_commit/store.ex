defmodule TwoPhaseCommit.Store do
  @moduledoc """
  The store specification.

  The store is responsible for persisting the state and transactions of an entity and enforces the constraints to apply transactions sequentially.

  A store used in the two-phase-commit approch must export hte following three functions:
  - `prepare/4` function which persists the prepared transaction;
  - `commit/3` function which persit the updated state;
  - `get/2` function which retrieves the current state of an entity with an optional pending transaction.
  """

  @typedoc "Module implementing the `TwoPhaseCommit.Store` behaviour."
  @type t :: module()

  @typedoc "Unique reference of an entity."
  @type ref :: any()

  @typedoc "The revision of the state of an entity."
  @type revision :: term()

  @typedoc "The state of an entity at a specific revision."
  @type state :: term()

  @typedoc "Module implementing the `TwoPhaseCommit.Action` behaviour."
  @type action :: module()

  @typedoc "A transaction contains all the information required to commit an action."
  @type transaction :: term()

  @typedoc "Unique reference of a transaction."
  @type transaction_ref :: term()

  @typedoc "Store error."
  @type on_error :: {:error, any()}

  @callback get(ref()) ::
              {:ok, revision(), state()}
              | {:pending, state(), action(), transaction(), transaction_ref()}

  @callback prepare(ref(), revision(), module(), transaction()) ::
              {:ok, transaction_ref()}
              | on_error()

  @callback commit(ref(), transaction_ref(), state()) ::
              {:ok, revision()}
              | on_error()
end
