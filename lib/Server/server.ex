defmodule BuildServer.Server do
  use GenServer

  # Client API

  def start_link(
    build_configuration,
    deploy_configuration,
    %DynamicState{} = dynamic_state) do
    GenServer.start_link(
      BuildServer.Server,
      %ServerState
      {
          build_configuration: build_configuration,
          deploy_configuration: deploy_configuration,
          dynamic_state: dynamic_state
      },
      name: BuildServer)
  end

  def init(%ServerState{dynamic_state: dynamic_state} = server_state) do
    IO.puts "Build server initializing..."
    IO.puts "Submitting a job to run every minute"
    Quantum.add_job("* * * * *", fn -> IO.puts "Ping" end)
    IO.puts "Server dynamic state is #{inspect dynamic_state}"
    {:ok, server_state}
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
  # def handle_call(:list_systems, _from, systems) do
  #   {:reply, systems, systems}
  # end
  #
  # def handle_call({:has_system, system}, _from, systems) do
  #   {:reply, contains_value(systems, system), systems}
  # end

  def handle_call({:get_configuration, system}, _from, %ServerState{deploy_configuration: deploy_configuration} = state) do
    {:reply, do_get_configuration(system, deploy_configuration), state}
  end

  def handle_call(
    {:schedule_deploy, system, schedule, build_client, options},
    _from,
    %ServerState{
      deploy_configuration: deploy_configuration,
      dynamic_state:
        %DynamicState
        {
          quantum_schedule: quantum_schedule,
          clients: clients
          } = dynamic_state} = state) do
    case deploy_configuration[system] do
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
        job =
        Quantum.add_job(
          schedule,
          fn -> invoke_client_deploy(
            clients[build_client |> extract_host_name], system, system |> get_configuration!(deploy_configuration), options)
          end)
        IO.puts "Scheduled invocation of deploy #{system} for #{inspect build_client} on #{schedule}"
        new_state = %{state | dynamic_state: %{dynamic_state | quantum_schedule: [job|quantum_schedule]}}
        {:reply, :ok, new_state}
      _ ->
        {
          :reply,
          {
            :failed,
            "System #{system} does not exist. Valid values are: #{deploy_configuration |> get_systems_string}"
          },
          state
        }
    end
  end

  def handle_call(
    {:schedule_build, system, schedule, build_client, options},
    _from,
    %ServerState{
      build_configuration: build_configuration,
      dynamic_state:
        %DynamicState
        {
          quantum_schedule: quantum_schedule,
          clients: clients
        } = dynamic_state} = state) do
    case build_configuration[system] do
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
        job =
        Quantum.add_job(
          schedule,
          fn -> invoke_client_build(
            clients[build_client |> extract_host_name], system, system |> get_configuration!(build_configuration), options)
          end)
        IO.puts "Scheduled invocation of build #{system} for #{inspect build_client} on #{schedule}"
        new_dynamic_state = %{dynamic_state | quantum_schedule: [job|quantum_schedule] }
        new_dynamic_state |> save_dynamic_server_state
        {:reply, :ok, %{state | dynamic_state: new_dynamic_state}}
      _ ->
        {
          :reply,
          {
            :failed,
            "System #{system} does not exist. Valid values are: #{build_configuration |> get_systems_string}"
          },
          state
        }
    end
  end

  def handle_call(:list_systems, _from, %ServerState{deploy_configuration: deploy_configuration} = state) do
    {:reply, deploy_configuration |> get_systems, state}
  end

  def handle_call(:list_commands, _from, %ServerState{} = state) do
    {:reply, list_commands, state}
  end

  def handle_call(:get_help, _from, %ServerState{deploy_configuration: deploy_configuration} = state) do
    {:reply, deploy_configuration |> get_help_string, state}
  end

  def handle_call(
    {:get_build_info, system},
    _from,
    %ServerState{build_configuration: build_configuration} = state) do
    scripts_dir = Application.get_env(:build_server, :scripts_dir)
    drop_location = build_configuration |> get_drop_location(system) |> String.replace("/", "\\")
    scripts_dir |> File.cd!
    IO.puts "Current directory: #{scripts_dir}"
    build_info =
    ~s/powershell .\\GetLatestBuild.ps1 "#{drop_location}"/
    |> String.to_char_list
    |> :os.cmd
    |> List.to_string
    IO.puts "PS Command result: #{build_info}"
    case build_info |> String.split("\r\n") do
      [latest_build, last_successful_build | _t] ->
        {:reply, %{latest_build: latest_build, last_successful_build: last_successful_build}, state}
      [latest_build|_t] ->
        {:reply, %{latest_build: latest_build}, state}
      [] ->
        {:reply, %{}, state}
      _ ->
        {:reply, :no_info, state}
    end
  end

  def handle_call({:build, system, build_client, _options}, _from, %ServerState{build_configuration: build_configuration} = state) do
    IO.puts "Starting build #{system} on #{inspect build_client} #{get_local_time_string}"
    build_client |> invoke_client_build(system, system |> get_configuration!(build_configuration))
    {:reply, :ok, state}
  end

  def handle_call(
    {:schedule_ping, schedule, {_process, node} = _client},
    _from,
    %ServerState{
      dynamic_state:
        %DynamicState{quantum_schedule: quantum_schedule, clients: clients} = dynamic_state
      } = state) do
    myself = self()
    job =
    Quantum.add_job(
      schedule,
      fn ->
        IO.puts "Sending ping to #{node} on #{get_local_time_string}"
        r = myself |> GenServer.call({:my_client, node |> extract_host_name}) |> GenServer.call(:ping)
        IO.puts "Result: #{r} came on #{get_local_time_string}"
      end)
    new_dynamic_state = %{dynamic_state | quantum_schedule: [job|quantum_schedule]}
    new_dynamic_state |> save_dynamic_server_state
    {:reply, :ok, %{state | dynamic_state: new_dynamic_state}}
  end

  def handle_call(
    {:connect, {_process, node} = client},
    _from,
    %ServerState
    {
      dynamic_state: %DynamicState{clients: clients} = dynamic_state
    } = state) do
    host = node |> to_string |> String.split("@") |> List.last
    new_clients = clients |> Map.put(host, client)
    new_dynamic_state = %{dynamic_state | clients: new_clients}
    new_dynamic_state |> save_dynamic_server_state
    {:reply, :ok, %{state | dynamic_state: new_dynamic_state}}
  end

  def handle_call({:my_client, host}, _from, %ServerState{dynamic_state: %DynamicState{clients: clients} = dynamic_state} = state) do
    {:reply, clients[host], state}
  end

  defp get_help_string(configuration) do
  """
  Command format = command [system] [options]
  command = #{get_commands_string}
  system = #{configuration |> get_systems_string}
  options = #{get_options_string}
  """
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
  defp do_get_configuration(system, configuration) do
    case configuration[system] do
      %{} = c -> {:configuration, c}
      _ -> {:unknown_system, "System #{system} is unknown to the build server"}
    end
  end

  defp get_configuration!(system, configuration) do
    case do_get_configuration(system, configuration) do
      {:configuration, c} -> c
      {:unknown_system, message} -> raise message
      _ -> raise "Failed to retrieve configuration for the system #{system}"
    end
  end

  defp invoke_client_deploy(client, system, configuration, options \\ []) do
    IO.puts "Invoking client deploy for system: #{system} on client #{inspect client}"
    GenServer.call(client, {:start_deploy, system, configuration, options})
  end

  defp invoke_client_build(client, system, configuration, options \\ []) do
    IO.puts "Invoking client build for system #{system} on client #{inspect client}"
    GenServer.call(client, {:start_build, system, configuration, options})
  end

  defp get_systems(configuration) do
    for {k, _v} <- configuration, into: [], do: k
  end

  defp get_systems_string(configuration, delimiter \\ " | ") do
    configuration |> get_systems |> Enum.join(delimiter)
  end

  defp get_options_string do
    "schedule time, i.e., hh:mm; etc. depending on command."
  end

  defp list_commands do
    [
      "deploy",
      "schedule_deploy",
      "h",
      "help",
      "get_configuration",
      "list_commands",
      "list_systems",
      "schedule_build",
      "build",
      "get_build_configuration",
      "get_build_info",
      "schedule_ping",
      "my_client"
    ]
  end

  defp get_commands_string do
    list_commands |> Enum.join(" | ")
    #for c <- list_commands, into: "", do: "#{c}\r\n"
  end

  defp get_drop_location(configuration, system) do
    configuration[system]["DropLocation"]
  end

  defp rjust(v, l \\ 2, c \\ ?0) do
    v |> to_string |> String.rjust(l, c)
  end

  defp get_local_time_string do
    {{year, month, day}, {hour, minute, second}} = :calendar.local_time
    "#{year}.#{month}#{day} at #{hour |> rjust}:#{minute |> rjust}:#{second |> rjust}"
  end

  def save_dynamic_server_state(%DynamicState{} = dynamic_server_state, filename \\ "serverstate.txt") do
    Application.get_env(:build_server, :home_dir) |> Path.join(filename) |> File.write!(dynamic_server_state |> inspect)
  end

  def restore_dynamic_server_state(filepath) do
    cond do
      filepath |> File.exists? ->
        {state, _bindings} = filepath |> File.read! |> Code.eval_string
        state
      true ->
        %DynamicState{}
    end
  end

  defp extract_host_name(node) do
    node |> to_string |> String.split("@") |> List.last
  end

end
