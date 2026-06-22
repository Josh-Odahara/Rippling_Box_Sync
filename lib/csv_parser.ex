defmodule RipplingBoxSync.CSVParser do
  NimbleCSV.define(RipplingBoxSync.CSVParser.Parser, separator: ",", escape: "\"")


  def parse(raw_csv) do
    {:ok, contents} = File.read(raw_csv)

    contents
    |> RipplingBoxSync.CSVParser.Parser.parse_string(skip_headers: true)
    |> Enum.map(fn[associate_id, first_name, last_name, department] ->
      %Employee{
        associate_id: associate_id,
        first_name: first_name,
        last_name: last_name,
        department: department
      }
    end)
  end

end
