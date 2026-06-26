defmodule Mix.Tasks.Sort do
  use Mix.Task

  def run(_args) do
    RipplingBoxSync.PhaseTwo.Sort.run("employees.csv")
  end
end
