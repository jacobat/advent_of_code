defmodule Day7 do
  def input do
    File.read!("input")
    # File.read!("test")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.sort
  end

  def min_distance(input, fun) do
    Enum.map(0..Enum.count(input), fn guess ->
      Enum.map(input, &(fun.(&1, guess)))
      |> Enum.sum
    end)
    |> Enum.min
  end

  def first(input) do
    min_distance(input, fn n, guess -> abs(n - guess) end)
  end

  def second(input) do
    min_distance(input, fn n, guess ->
      div(abs(n - guess) * (abs(n - guess) + 1), 2)
    end)
  end

  def run do
    first(input()) |> IO.inspect(limit: :infinity, label: "First")
    second(input()) |> IO.inspect(limit: :infinity, label: "Second")
  end
end

Day7.run()
