defmodule BuildServer do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(
        BuildServer.Server,
        [
          Application.get_env(:build_server, :build_configuration, %{}),
           Application.get_env(:build_server, :deploy_configuration, %{}),
           Application.get_env(:build_server, :home_dir, "")
           |> Path.join("serverstate.txt")
           |> BuildServer.Server.restore_dynamic_server_state
         ])
      # Define workers and child supervisors to be supervised
      # worker(BuildServer.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BuildServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
