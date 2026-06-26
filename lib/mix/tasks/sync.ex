defmodule Mix.Tasks.Sync do
  use Mix.Task

  def run(_args) do
    RipplingBoxSync.PhaseOne.Sync.run("employees.csv")
  end
end
