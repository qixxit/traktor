defmodule TwoPhaseCommit.Store do
  @moduledoc """
    The store specification.

  A store defines the persistance layer for actions executed in a two-phase-commit approch.
  A module providing the persistance logic must export the following three functions:
  - `prepare/4` function which persists the prepared data from the prepare action
  - `commit/3` function which persit the outcome of the commit action
  - `get/2` function which retrieves the entity and all required information to resume a transaction if necessary.
  """
  @type t :: module()

  @typedoc "Unique reference for the entity. "
  @type ref :: any()
  @typedoc "The entity revision."
  @type revision :: term()
  @typedoc "The state of an entity at a specific revision."
  @type state :: term()

  @typedoc "Module implementing the `TwoPhaseCommit.Action` behaviour."
  @type action :: module()
  @typedoc "A transaction contains all the information required to commit an action."
  @type transaction :: term()
  @typedoc "Unique reference for a transaction."
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
