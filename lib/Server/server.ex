defmodule BuildServer.Server do
  use GenServer

  # Client API

  def start_link(configuration) do
    GenServer.start_link(BuildServer.Server, configuration, name: BuildServer)
  end

  def init(%{} = configuration) do
    IO.puts "Build server initializing..."
    IO.puts "Submitting a job to run every minute"
    Quantum.add_job("* * * * *", fn -> IO.puts "Ping" end)
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

  def handle_call({:schedule_deploy, system, schedule, build_client, options}, _from, state) do
    case state[system] do
      %{} ->
        # job = %Quantum.Job
        # {
        #     schedule: schedule,
        #     task:
        #       fn -> invoke_client_deploy(
        #         build_client, system, system |> get_configuration!(state), options)
        #       end
        # }
        # Quantum.add_job("Deploy #{system} on #{inspect build_client}", job)
        Quantum.add_job(
          schedule,
          fn -> invoke_client_deploy(
            build_client, system, system |> get_configuration!(state), options)
          end)
        IO.puts "Scheduled invocation of deploy #{system} for #{inspect build_client} on #{schedule}"
        {:reply, :ok, state}
      _ ->
        {
          :reply,
          {
            :failed,
            "System #{system} does not exist. Valid values are: #{state |> get_systems_string}"
          },
          state
        }
    end
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

  defp get_configuration!(system, state) do
    case do_get_configuration(system, state) do
      {:configuration, c} -> c
      {:unknown_system, message} -> raise message
      _ -> raise "Failed to retrieve configuration for the system #{system}"
    end
  end

  defp invoke_client_deploy(client, system, configuration, options \\ []) do
    IO.puts "Invoking client deploy for system: #{system} on client #{inspect client}"
    GenServer.call(client, {:start_deploy, system, configuration, options})
  end

  defp get_systems(state) do
    for {k, _v} <- state, into: [], do: k
  end

  defp get_systems_string(state, delimiter \\ ", ") do
    state |> get_systems |> Enum.join(delimiter)
  end

end
