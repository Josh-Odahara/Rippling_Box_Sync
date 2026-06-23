defmodule RipplingBoxSync.Box do
  alias RipplingBoxSync.Rippling

  def build_folder_name(first_name, last_name, associate_id) do
    "#{last_name}, #{first_name} - #{associate_id}"
  end

  def create_employee_folder(%Employee{first_name: first_name, last_name: last_name, associate_id: associate_id}) do
    folder_name = build_folder_name(first_name, last_name, associate_id)
    folder_path = Path.join("box_storage", folder_name)
    File.mkdir_p!(folder_path)
    folder_path
  end

  def upload_file(folder_path, %{filename: filename, content: content}) do
    file_path = Path.join(folder_path, filename)
    File.write!(file_path, content)
  end

end
