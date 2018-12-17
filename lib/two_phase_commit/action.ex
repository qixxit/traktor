defmodule TwoPhaseCommit.Action do
  @type t :: module()

  @type state :: term()
  @type args :: any()
  @type transaction :: term()

  @type on_error :: {:error, reason :: any()}

  @callback prepare(state(), args()) ::
              {:ok, transaction()}
              | on_error()

  @callback commit(state(), transaction()) ::
              {:ok, state(), result :: any()}
              | on_error()
end
