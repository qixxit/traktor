defmodule TwoPhaseCommit.Action do
  @moduledoc """
    The action specification.

    An action defines the business logic that is executed in a two-phase-commit approch. A module providing the busness logic must export the following two functions:
    - `prepare/2` function that prepares the execution of the businses logic;
    - `commit/2` function that executes the business logic.

    Calling the two functions after each other will run the business logic and return the result.
    ```
      with {:ok, transaction} <- prepare(state, args),
           {:ok, new_state, result} <- commit(state, transaction) do
        {:ok, new_state, result}
      end
    ```
  """

  @typedoc "Module implementing the `TwoPhaseCommit.Action` behaviour."
  @type t :: module()

  @typedoc "The state of an entity at a specific revision."
  @type state :: term()

  @typedoc "Specific arguments required to apply an action to an entity."
  @type args :: any()

  @typedoc "A transaction contains all the information required to commit an action."
  @type transaction :: term()

  @typedoc "Data resulting from commiting an action that is not included in the entity state."
  @type result :: any()

  @typedoc "Action error."
  @type on_error :: {:error, reason :: any()}

  @callback prepare(state(), args()) ::
              {:ok, transaction()}
              | on_error()

  @callback commit(state(), transaction()) ::
              {:ok, state(), result()}
              | on_error()
end
