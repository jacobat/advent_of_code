defmodule Day1 do
  # def input, do: File.read!("test")
  def input, do: File.read!("input")

  def input_lines do
    input()
    |> String.split("\n")
    |> Enum.reject(&(String.length(&1) == 0))
    |> Enum.map(&String.to_integer/1)
  end

  def chunks(size), do: input_lines() |> Enum.chunk_every(size, 1, :discard)

  def count_increases do
    chunks(2)
    |> count_increases()
  end

  def count_window_increases do
    chunks(3)
    |> Enum.map(&Enum.sum/1)
    |> Enum.chunk_every(2, 1, :discard)
    |> count_increases()
  end

  def count_increases(list) do
    list
    |> Enum.filter(fn [a,b] -> a < b end)
    |> Enum.count
  end

  def run do
    %{ increases: count_increases(),
      window_increases: count_window_increases()
    }
  end
end

IO.inspect(Day1.run, limit: :infinity)
