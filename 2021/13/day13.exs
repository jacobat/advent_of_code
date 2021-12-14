defmodule Day13 do
  def input do
    File.read!("input")
    # File.read!("test")
    |> String.trim
    |> String.split("\n")
    |> Enum.split_while(&String.length(&1) > 0)
    |> parse
  end

  def parse({coords, folds}), do: %{coords: parse_coords(coords), folds: parse_folds(folds)}

  def parse_coords(coords), do: Enum.map(coords, &String.split(&1, ",") |> parse_ints)

  def parse_ints([a, b]), do: [String.to_integer(a), String.to_integer(b)]

  def parse_folds(folds) do
    Enum.reject(folds, &String.length(&1) == 0)
    |> Enum.map(&parse_fold/1)
  end

  def parse_fold(fold) do
    [dim, coord] = Regex.run(~r/fold along (.*)\D(.*)/, fold, capture: :all_but_first)
    [dim, String.to_integer(coord)]
  end

  def fold_coord(["x", o], [x, y]), do: [o - (abs(x - o)), y]
  def fold_coord(["y", o], [x, y]), do: [x, o - (abs(y - o))]

  def fold_at(fold, coords), do: Enum.map(coords, &fold_coord(fold, &1))

  def print(coords) do
    max_x = Enum.map(coords, &List.first/1)
            |> Enum.max
    max_y = Enum.map(coords, &List.last/1)
            |> Enum.max

    for y <- 0..max_y do
      Enum.map(0..max_x, fn x ->
        if Enum.member?(coords, [x, y]), do: "#", else: "."
      end)
      |> Enum.join
      |> IO.puts
    end
    coords
  end

  def first(input) do
    input[:folds]
    |> Enum.take(1)
    |> Enum.reduce(input[:coords], &fold_at/2)
    |> Enum.uniq
    |> Enum.count
  end

  def second(input) do
    input[:folds]
    |> Enum.reduce(input[:coords], &fold_at/2)
  end

  def run do
    with input <- input()
    do
      first(input)
      |> IO.inspect(charlists: :as_lists, limit: :infinity, label: "First")
      IO.puts("Second:")
      second(input)
      |> print
      # |> IO.inspect(charlists: :as_lists, limit: :infinity, label: "Second")
    end
  end
end
IO.puts("")
IO.puts("***************************")
IO.puts("******** New run **********")
IO.puts("***************************")
IO.puts("")

:timer.tc(Day13, :run, [])
|> elem(0)
|> div(1000)
|> then(&IO.puts("Runtime: #{&1}ms"))
