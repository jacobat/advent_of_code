defmodule Day6 do
  def input do
    File.read!("input")
    # File.read!("test")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.frequencies
  end

  def step(frequencies) do
    frequencies
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      case key do
        0 -> Map.merge(%{6 => value, 8 => value}, acc, fn _k, v1, v2 -> v1 + v2 end)
        _ -> Map.merge(%{key - 1 => value}, acc, fn _k, v1, v2 -> v1 + v2 end)
      end
    end)
    |> Enum.into(%{})
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
