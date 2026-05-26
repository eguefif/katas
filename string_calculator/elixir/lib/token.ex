defmodule Token do
  defstruct [:value, :position, :type]

  def new(position) do
    %Token{value: "", position: position, type: :num}
  end
end
