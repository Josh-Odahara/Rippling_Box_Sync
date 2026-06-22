defmodule Employee do
  @enforce_keys [:associate_id, :first_name, :last_name, :department]
  defstruct [:associate_id, :first_name, :last_name, :department]
end
