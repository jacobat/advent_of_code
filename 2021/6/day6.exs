defmodule Day6 do
  def input do
    File.read!("input")
    # File.read!("test")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.frequencies
  end

  def sum_values(m1, m2), do: Map.merge(m1, m2, fn _k, v1, v2 -> v1 + v2 end)

  def step_fun({0, value}, acc), do: sum_values(%{6 => value, 8 => value}, acc)
  def step_fun({key, value}, acc), do: sum_values(%{key - 1 => value}, acc)

  def step(frequencies) do
    Enum.reduce(frequencies, %{}, &step_fun/2)
  end

  def fish_after_days(days) do
    input()
    |> Stream.iterate(&step/1)
    |> Stream.drop(days)
    |> Stream.take(1)
    |> Enum.to_list
    |> List.first
    |> Map.values
    |> Enum.sum
  end

  def first, do: fish_after_days(80)

  def second, do: fish_after_days(256)

  def run do
    first() |> IO.inspect(limit: :infinity, label: "First")
    second() |> IO.inspect(limit: :infinity, label: "Second")
  end
end

Day6.run()
