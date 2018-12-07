defmodule Solution do
  def solution do
    File.read!("input.txt")
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum
  end
end
