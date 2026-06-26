defmodule RipplingBoxSync.PhaseOne.Sync do
  alias RipplingBoxSync.Rippling
  alias RipplingBoxSync.Box
  alias RipplingBoxSync.CSVParser

  def sync_employee(
        %Employee{
          first_name: _first_name,
          last_name: _last_name,
          associate_id: _associate_id
        } =
          employee
      ) do
    case Rippling.fetch_employee_docs(employee) do
      {:ok, docs} ->
        folder_path = Box.create_employee_folder(employee)
        Enum.each(docs, fn doc -> Box.upload_file(folder_path, doc) end)

      {:error, reason} ->
        Box.create_retry_folder(employee, reason)
    end
  end

  def run(csv_path) do
    employees = CSVParser.parse(csv_path)
    Enum.each(employees, fn employee -> sync_employee(employee) end)
  end
end
