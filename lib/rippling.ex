defmodule RipplingBoxSync.Rippling do
  def fetch_employee_docs(
        %Employee{associate_id: associate_id, first_name: first_name, last_name: last_name} =
          _employee
      ) do
    # hardcoded failure case for testing retry logic
    if associate_id == "1001" do
      {:error, "Failed to fetch docs for #{first_name} #{last_name} (#{associate_id})"}
    else
      {:ok,
       [
         %{
           doc_type: "I-9",
           extension: "pdf",
           filename: build_filename(first_name, last_name, associate_id, "I-9", "pdf"),
           content: "mock binary data"
         },
         %{
           doc_type: "W-2",
           extension: "pdf",
           filename: build_filename(first_name, last_name, associate_id, "W-2", "pdf"),
           content: "mock binary data"
         },
         %{
           doc_type: "offer_letter",
           extension: "pdf",
           filename: build_filename(first_name, last_name, associate_id, "offer_letter", "pdf"),
           content: "mock binary data"
         },
         %{
           doc_type: "i9_support",
           extension: "jpg",
           filename: "IMG_5545.jpg",
           content: "mock binary data"
         }
       ]}
    end
  end

  defp build_filename(first_name, last_name, associate_id, doc_type, extension) do
    "Employee File - #{first_name} #{last_name} - #{associate_id} - #{doc_type}.#{extension}"
  end
end
