defmodule Mix.Tasks.Yarn do
  @moduledoc "installs Yarn dependencies"

  def run(_) do
    System.cmd("yarn", ["--cwd ../../../assets", "install"])
  end
end
