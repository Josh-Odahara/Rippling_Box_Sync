defmodule RipplingBoxSync.PhaseTwo.Scanner do
  alias RipplingBoxSync.PhaseTwo.Keywords

  @spec score_doc(%{:content => binary(), :filename => binary(), optional(any()) => any()}) ::
          non_neg_integer()
  def score_doc(%{
        filename: filename,
        content: content
      }) do
    downcased_filename = String.downcase(filename)
    downcased_content = String.downcase(content)
    keywords = Keywords.i9_keywords()
    downcased_keywords = Enum.map(keywords, fn keyword -> String.downcase(keyword) end)

    filename_count =
      Enum.count(downcased_keywords, fn keyword ->
        String.contains?(downcased_filename, keyword)
      end)

    content_count =
      Enum.count(downcased_keywords, fn keyword ->
        String.contains?(downcased_content, keyword)
      end)

    filename_count + content_count
  end

  def i9_related?(doc) do
    score_doc(doc) >= 3
  end
end
