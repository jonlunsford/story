defmodule Mix.Tasks.Npm do
  @moduledoc "installs npm dependencies"

  use Mix.Task

  @shortdoc "Installs npm dependencies"
  def run(_) do
    IO.puts("----------- Installing npm dependencies --------------")

    File.cd!("./assets", fn() ->
      System.cmd("npm", ["install"])
    end)
  end
end
