defmodule Day1 do
  # def input, do: File.read!("test")
  def input, do: File.read!("input")

  def count_increases(window_size) do
    input()
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(window_size, 1, :discard)
    |> Enum.map(&Enum.sum/1)
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.filter(fn [a,b] -> a < b end)
    |> Enum.count
  end

  def run do
    %{
      increases: count_increases(1),
      window_increases: count_increases(3)
    }
  end
end

IO.inspect(Day1.run, limit: :infinity)
