defmodule RipplingBoxSync.Rippling do
  def fetch_employee_docs(
        %Employee{associate_id: associate_id, first_name: first_name, last_name: last_name} =
          _employee
      ) do
        if first_name == "" or last_name == "" do
          {:error, "Missing cells on CSV"}
        else
                {:ok,
       [
         %{
           doc_type: "I-9",
           extension: "pdf",
           filename: build_filename(first_name, last_name, associate_id, "I-9", "pdf"),
           content: "Form I-9, Employment Eligibility Verification from the Department of Homeland Security"
         },
         %{
           doc_type: "W-2",
           extension: "pdf",
           filename: build_filename(first_name, last_name, associate_id, "W-2", "pdf"),
           content: "tax withholdings"
         },
         %{
           doc_type: "offer_letter",
           extension: "pdf",
           filename: build_filename(first_name, last_name, associate_id, "offer_letter", "pdf"),
           content: "start date, compensation"
         },
         %{
           doc_type: "i9_support",
           extension: "jpg",
           filename: "IMG_5545.jpg",
           content: "Washington State Driver's License, Valid US passport, Social Security Card"
         }
       ]}
        end
    end


  defp build_filename(first_name, last_name, associate_id, doc_type, extension) do
    "Employee File - #{first_name} #{last_name} - #{associate_id} - #{doc_type}.#{extension}"
  end
end
