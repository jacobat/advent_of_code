defmodule Day9 do
  def input do
    File.read!("input")
    # File.read!("test")
    |> String.trim
    |> String.split("\n")
    |> Enum.map(&String.codepoints/1)
    |> Enum.map(fn codepoints -> Enum.map(codepoints, &String.to_integer/1) end)
    |> Enum.map(&List.to_tuple/1)
    |> List.to_tuple
  end

  def get_pos(map, {x, y}), do: elem(map, y) |> then(&elem(&1, x))

  def add_pos({x0, y0}, {x1, y1}), do: { x0 + x1, y0 + y1 }

  def valid_pos?(map, {x, y}) do
    with width <- tuple_size(elem(map, 0)),
         height <- tuple_size(map)
    do
      (x >= 0) && (x < width) && (y >= 0) && (y < height)
    end
  end

  def neighbours(map, position) do
    [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]
    |> Enum.reduce(MapSet.new(), fn offset, acc ->
      n_pos = add_pos(position, offset)
      if valid_pos?(map, n_pos) do
        MapSet.put(acc, n_pos)
      else
        acc
      end
    end)
  end

  def lower_than_neighbours(map, pos) do
    neighbours(map, pos)
    |> Enum.map(&get_pos(map, &1))
    |> Enum.all?(fn n -> n > get_pos(map, pos) end)
  end

  def low_points(map) do
    for y <- 0..(tuple_size(map) - 1),
      x <- 0..(tuple_size(elem(map, 0)) - 1),
      lower_than_neighbours(map, {x, y}),
      do: {x, y}
  end

  def total_risk_level(low_points, map) do
    low_points
    |> Enum.map(&get_pos(map, &1))
    |> Enum.map(&(&1+1))
    |> Enum.sum
  end

  def first(input) do
    low_points(input) |> total_risk_level(input)
  end

  def peak?(map, position), do: get_pos(map, position) == 9

  def expand_basin(_, [], checked_positions), do: checked_positions

  def expand_basin(map, positions, checked_positions) do
    valid_positions = Enum.reject(positions, &peak?(map, &1))
    new_neighbours = Enum.into(valid_positions, MapSet.new(), &neighbours(map, &1))
                 |> Enum.reduce(MapSet.new(), &MapSet.union/2)
                 |> MapSet.difference(checked_positions)
                 |> MapSet.to_list
    new_checked = MapSet.new(valid_positions) |> MapSet.union(checked_positions)
    expand_basin(map, new_neighbours, new_checked)
  end

  def expand_basin(map, position) do
    expand_basin(map, [position], MapSet.new())
  end

  def second(input) do
    low_points(input)
    |> Enum.map(&expand_basin(input, &1))
    |> Enum.map(&Enum.count/1)
    |> Enum.sort
    |> Enum.reverse
    |> Enum.take(3)
    |> Enum.product
  end

  def run do
    with input <- input()
    do
      first(input)
      |> IO.inspect(charlists: :as_lists, limit: :infinity, label: "First")
      second(input)
      |> IO.inspect(charlists: :as_lists, limit: :infinity, label: "Second")
    end
  end
end

:timer.tc(Day9, :run, [])
|> elem(0)
|> div(1000)
|> then(&IO.puts("Runtime: #{&1}ms"))
