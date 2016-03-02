defmodule BuildServer.Server do
  use GenServer

  # Client API

  def start_link(configuration) do
    GenServer.start_link(BuildServer.Server, configuration, name: BuildServer)
  end

  def init(%{} = configuration) do
    {:ok, configuration}
  end

  def list_systems do
    GenServer.call(BuildServer, :list_systems)
  end

  def has_system(system) do
    GenServer.call(BuildServer, {:has_system, system})
  end

  def get_configuration(system) do
    GenServer.call(BuildServer, {:get_configuration, system})
  end

  #Server callbacks
  def handle_call(:list_systems, _from, systems) do
    {:reply, systems, systems}
  end

  def handle_call({:has_system, system}, _from, systems) do
    {:reply, contains_value(systems, system), systems}
  end

  def handle_call({:get_configuration, system}, _from, state) do
    {:reply, do_get_configuration(system, state), state}
  end

  # Helpers
  defp contains_value([], _v) do
    false
  end

  defp contains_value([v|t], v) do
    true
  end

  defp contains_value([h|t], v) do
    contains_value(t, v)
  end

  # Internal BL
  defp do_get_configuration(system, state) do
    case state[system] do
      %{} = c -> {:configuration, c}
      _ -> {:unknown_system, "System #{system} is unknown to the build server"}
    end
  end

end
