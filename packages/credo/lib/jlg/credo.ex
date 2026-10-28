defmodule JLG.Credo do
  @moduledoc """
  The canonical Credo config, registered as the default config every project's
  `.credo.exs` merges over.
  """

  alias Credo.Plugin

  @external_resource config = Path.expand("../../credo.exs", __DIR__)
  @config File.read!(config)

  @spec init(Credo.Execution.t()) :: Credo.Execution.t()
  def init(exec), do: Plugin.register_default_config(exec, @config)
end
