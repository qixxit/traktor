defmodule TwoPhaseCommit.Action do
  @moduledoc """
    The action specification.

    An action defines the business logic that is executed in a two-phase-commit approch. A module providing the busness logic must export the folloing two functions:
      * a `prepare/2` function that prepares the execution of the businses logic, and
      * a `commit/2` function that executes the business logic.

    Calling the two functions after each other will run the business logic and return the result.

        with {:ok, transaction} <- prepare(state, args),
             {:ok, new_state, result} <- commit(state, transaction) do
          {:ok, new_state, result}
        end

    Splitting the business logic into the _prepare_ and the _commit_ allows persiting the transaction before commiting the action to be able to recover in case of an failure. Therefore the transaction must contain the all data required to execute the action and to identify an potential previous execution. For example the transaction might contain all request parameters together with a unique request_id. This request_id allows identifying the request at the 3rd party.
  """

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
