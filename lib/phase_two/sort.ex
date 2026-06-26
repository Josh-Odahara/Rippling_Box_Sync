defmodule RipplingBoxSync.PhaseTwo.Sort do
  alias RipplingBoxSync.PhaseTwo.Scanner
  alias RipplingBoxSync.Box
  alias RipplingBoxSync.CSVParser

  def sort_employee(employee) do
    folder_name =
      Box.build_folder_name(employee.first_name, employee.last_name, employee.associate_id)

    folder_path = Path.join("box_storage", folder_name)

    case File.ls(folder_path) do
      {:ok, filenames} ->
        i9_filenames =
          Enum.filter(filenames, fn filename ->
            full_path = Path.join(folder_path, filename)
            {:ok, contents} = File.read(full_path)
            doc = %{filename: filename, content: contents}
            Scanner.i9_related?(doc)
          end)

        Enum.each(i9_filenames, fn filename ->
          source_path = Path.join(folder_path, filename)
          new_folder_path = Path.join("box_storage/I9_files", folder_name)
          File.mkdir_p!(new_folder_path)
          destination_path = Path.join(new_folder_path, filename)
          File.rename!(source_path, destination_path)
        end)

      {:error, reason} ->
        IO.puts(
          "Failed to sort #{employee.first_name} #{employee.last_name} - #{employee.associate_id}, #{reason}"
        )
    end
  end

  def run(csv_path) do
    employees = CSVParser.parse(csv_path)

    Enum.each(employees, fn employee ->
      sort_employee(employee)
    end)
  end
end
