defmodule ServerState do
  defstruct build_configuration: nil, deploy_configuration: nil, dynamic_state: %DynamicState{}
end
