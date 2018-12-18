defmodule TwoPhaseCommit.Server do
  use GenServer

  def start_link(ref, store, options \\ []) do
    GenServer.start_link(__MODULE__, [ref, store], options)
  end

  def call(ref, action, args) do
    GenServer.call(ref, {:apply_action, action, args})
  end

  def cast(ref, action, args) do
    GenServer.cast(ref, {:apply_action, action, args})
  end

  ##
  ## State
  ##

  defmodule State do
    defstruct [
      :ref,
      :store,
      :revision,
      :data
    ]
  end

  ##
  ## GenServer Callbacks
  ##

  def init([ref, store]) do
    state = %State{
      ref: ref,
      store: store
    }

    {:ok, state, {:continue, :load}}
  end

  def handle_continue(:load, state) do
    case state.store.get(state.ref) do
      {:ok, revision, data} ->
        new_state = %State{
          state
          | revision: revision,
            data: data
        }

        {:noreply, new_state}

      {:pending, data, action, transaction, transaction_ref} ->
        with {:ok, new_data, new_revision, _result} <-
               TwoPhaseCommit.commit(
                 action,
                 data,
                 transaction,
                 state.store,
                 state.ref,
                 transaction_ref
               ) do
          new_state = %State{
            state
            | revision: new_revision,
              data: new_data
          }

          {:noreply, new_state}
        else
          {:error, reason} ->
            {:stop, reason}
        end

      {:error, reason} ->
        {:stop, reason}
    end
  end

  def handle_call({:apply_action, action, args}, _from, state) do
    with {:ok, new_data, new_revision, result} <-
           TwoPhaseCommit.apply(action, state.data, args, state.store, state.ref, state.revision) do
      new_state = %State{
        state
        | revision: new_revision,
          data: new_data
      }

      {:reply, result, new_state}
    else
      {:error, reason} ->
        {:stop, reason}
    end
  end

  def handle_cast({:apply_action, action, args}, state) do
    with {:ok, new_data, new_revision, _result} <-
           TwoPhaseCommit.apply(action, state.data, args, state.store, state.ref, state.revision) do
      new_state = %State{
        state
        | revision: new_revision,
          data: new_data
      }

      {:noreply, new_state}
    else
      {:error, reason} ->
        {:stop, reason}
    end
  end
end
