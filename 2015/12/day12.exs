defmodule Day12 do
  def input, do: File.read!("input")

  def first(input) do
    Regex.scan(~r/(-?[0-9]+)/, input, capture: :all_but_first)
    |> List.flatten
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum
  end

  def second(input) do
    input
  end

  def run() do
    with input <- input()
    do
      first(input)
      |> IO.inspect(label: "First")
      # second(input)
      # |> IO.inspect(label: "Second")
    end
  end
end

Day12.run()
