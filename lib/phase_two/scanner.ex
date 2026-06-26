defmodule RipplingBoxSync.PhaseTwo.Scanner do
  alias RipplingBoxSync.PhaseTwo.Keywords

  def score_doc(%{
        doc_type: _doc_type,
        extension: _extension,
        filename: filename,
        content: content
      }) do
    downcased_filename = String.downcase(filename)
    downcased_content = String.downcase(content)
    keywords = Keywords.i9_keywords()
    downcased_keywords = Enum.map(keywords, fn keyword -> String.downcase(keyword) end)

    filename_count = Enum.count(downcased_keywords, fn keyword -> String.contains?(downcased_filename, keyword) end)
    content_count = Enum.count(downcased_keywords, fn keyword -> String.contains?(downcased_content, keyword) end)

    filename_count + content_count
  end
end
