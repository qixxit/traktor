defmodule TwoPhaseCommit.Store do
  @type t :: module()

  @type ref :: any()
  @type revision :: term()
  @type state :: term()

  @type action :: module()
  @type transaction :: term()
  @type transaction_ref :: term()

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
