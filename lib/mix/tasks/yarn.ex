defmodule Mix.Tasks.Yarn do
  @moduledoc "installs Yarn dependencies"
  use Mix.Task

  def run(_) do
    IO.puts("----------- Intalling yarn dependencies --------------")
    System.cmd("yarn", ["--cwd ../../../assets", "install"])
  end
end
