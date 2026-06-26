defmodule RipplingBoxSync.PhaseTwo.Scanner do
  alias RipplingBoxSync.PhaseTwo.Keywords

  def score_doc(%{doc_type: _doc_type, extension: _extension, filename: filename, content: _content}) do
    downcased_filename = String.downcase(filename)
    keywords = Keywords.i9_keywords()
    downcased_keywords = Enum.map(keywords, fn keyword -> String.downcase(keyword) end)
    Enum.count(downcased_keywords, fn keyword -> String.contains?(downcased_filename, keyword) end)
  end


end
