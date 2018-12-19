defmodule TwoPhaseCommit.Store.InMemory do
  @behaviour GenServer
  @behaviour TwoPhaseCommit.Store

  ##
  ## API
  ##

  @doc "Initialize the in memory store and returns the PID to be used as Entity ref."
  def start_link(initial) do
    GenServer.start_link(__MODULE__, initial)
  end

  ##
  ## Store Callbacks
  ##

  @impl TwoPhaseCommit.Store
  def get(ref) do
    GenServer.call(ref, :get)
  end

  @impl TwoPhaseCommit.Store
  def prepare(ref, revision, action, transaction) do
    GenServer.call(ref, {:prepare, revision, action, transaction})
  end

  @impl TwoPhaseCommit.Store
  def commit(ref, transaction_ref, state) do
    GenServer.call(ref, {:commit, transaction_ref, state})
  end

  ##
  ## State
  ##

  defmodule State do
    defstruct [
      :data,
      :revision,
      :action,
      :transaction,
      :transaction_ref
    ]
  end

  ##
  ## GenServer Callabcks
  ##

  @impl GenServer
  def init(initial) do
    state = %State{
      data: initial,
      revision: 0
    }

    {:ok, state}
  end

  @impl GenServer
  def handle_call(:get, _from, state) do
    do_get(state)
  end

  def handle_call({:prepare, revision, action, transaction}, _from, state) do
    do_prepare(revision, action, transaction, state)
  end

  def handle_call({:commit, transaction_ref, data}, _from, state) do
    do_commit(transaction_ref, data, state)
  end

  ##
  ## Private
  ##

  defp do_get(%State{transaction: nil} = state) do
    {:reply, {:ok, state.revision, state.data}, state}
  end

  defp do_get(state) do
    {:reply, {:pending, state.data, state.action, state.transaction, state.transaction_ref},
     state}
  end

  defp do_prepare(
         revision,
         action,
         transaction,
         %State{revision: revision, transaction: nil} = state
       ) do
    transaction_ref = make_ref()

    new_state = %State{
      state
      | action: action,
        transaction: transaction,
        transaction_ref: transaction_ref
    }

    {:reply, {:ok, transaction_ref}, new_state}
  end

  defp do_prepare(_revision, _action, _transaction, state) do
    {:reply, {:error, :conflict}, state}
  end

  defp do_commit(
         transaction_ref,
         data,
         %State{transaction_ref: transaction_ref, transaction: transaction} = state
       )
       when not is_nil(transaction) do
    new_revision = state.revision + 1

    new_state = %State{
      state
      | action: nil,
        transaction: nil,
        transaction_ref: nil,
        data: data,
        revision: new_revision
    }

    {:reply, {:ok, new_revision}, new_state}
  end

  defp do_commit(_transaction_ref, _data, state) do
    {:reply, {:error, :conflict}, state}
  end
end
