defmodule Day17 do
  # def input, do: File.read!("test")
  def input, do: File.read!("input")

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def fit(_, 0, path), do: [path]
  def fit([], _, _), do: []

  def fit(containers, volume, path) do
    # IO.inspect({containers, volume, path})
    Enum.with_index(containers)
    # |> IO.inspect
    |> Enum.flat_map(fn {container, index} ->
      if container <= volume do
        containers
        |> Enum.drop(index + 1)
        |> fit(volume - container, [container | path])
      else
        []
      end
    end)
  end

  def fit(containers, volume) do
    fit(containers, volume, [])
  end

  def fill(input, volume) do
    input
    |> Enum.sort
    |> Enum.reverse
    |> fit(volume)
  end

  def first(input) do
    input
    |> fill(150)
    |> Enum.count
  end

  def second(input) do
    solves = input
    |> fill(150)
    min_jars = solves
    |> Enum.map(&Enum.count/1)
    |> Enum.min
    solves
    |> Enum.filter(fn s -> Enum.count(s) == min_jars end)
    |> Enum.count
  end

  def run() do
    with input <- input() |> parse
    do
      first(input)
      |> IO.inspect(label: "First")
      second(input)
      |> IO.inspect(label: "Second")
    end
  end
end

IO.puts(String.duplicate("*", 60))
IO.puts(String.pad_leading(" Running ", 34, "*") |> String.pad_trailing(60, "*"))
IO.puts(String.duplicate("*", 60))
IO.puts("")

Day17.run()
