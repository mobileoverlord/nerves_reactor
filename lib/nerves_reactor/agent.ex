defmodule Nerves.Reactor.Agent do
  @doc """
  Starts a new agent.
  """
  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  @doc """
  Gets a value from the agent by `key`.
  """
  def get(key) do
    Agent.get(__MODULE__, &Keyword.get(&1, key))
  end

  def get() do
    Agent.get(__MODULE__, & &1)
  end

  @doc """
  Puts the `value` for the given `key` in the agent.
  """
  def put(key, value) do
    Agent.update(__MODULE__, &Keyword.put(&1, key, value))
  end
end
