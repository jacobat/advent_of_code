defmodule Day11 do
  @offsets [{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 0}, {0, 1}, {1, -1}, {1, 0}, {1, 1}]

  def input do
    File.read!("input")
    # File.read!("test")
    |> String.trim
    |> String.split("\n")
    |> Enum.map(&String.codepoints/1)
    |> Enum.map(fn l -> Enum.map(l, &String.to_integer/1) end)
    |> Enum.with_index(fn line, y ->
      Enum.with_index(line, fn cell, x -> %{{x, y} => cell}
      end)
    end)
    |> List.flatten
    |> Enum.reduce(%{}, &Map.merge/2)
  end

  def increase_cell(pos, map), do: Map.update!(map, pos, &(&1+1))

  def increase(map, cells), do: Enum.reduce(cells, map, &increase_cell/2)

  def add_pos({x0, y0}, {x1, y1}), do: { x0 + x1, y0 + y1 }

  def valid_pos?(map, position), do: Map.has_key?(map, position)

  def add_neighbours(position), do: Enum.map(@offsets, &add_pos(&1, position))

  def with_neighbours(positions, map) do
    positions
    |> Enum.flat_map(&add_neighbours/1)
    |> Enum.filter(&valid_pos?(map, &1))
  end

  def flashing_cells(map) do
    map |> Enum.filter(fn {_, cell} -> cell > 9 end) |> Enum.map(&elem(&1, 0))
  end

  def cells_to_increment(map, flashing_cells, already_flashed) do
    (flashing_cells -- already_flashed) |> with_neighbours(map)
  end

  def flash(map, already_flashed) do
    flashing_cells = flashing_cells(map)
    cells = cells_to_increment(map, flashing_cells, already_flashed)
    if Enum.empty?(cells) do
      map
    else
      map
      |> increase(cells)
      |> flash(flashing_cells ++ already_flashed)
    end
  end

  def flash(map), do: flash(map, [])

  def reset_flashed(map) do
    map
    |> Enum.reduce(%{}, fn {pos, cell}, acc ->
      value = if cell > 9, do: 0, else: cell
      Map.put(acc, pos, value)
    end)
  end

  def step(map) do
    map
    |> increase(Map.keys(map))
    |> flash
    |> reset_flashed
  end

  def display(map) do
    IO.puts("")
    for y <- 0..9 do
      for x <- 0..9 do
        value = map[{x, y}]
        cond do
          value == 10 -> IO.write("x")
          value > 10 -> IO.write(".")
          true -> IO.write(value)
        end
      end
      IO.write("\n")
    end
    map
  end

  def count_flashes(map) do
    map
    |> Map.values
    |> Enum.count(&(&1 == 0))
  end

  def first(input) do
    input
    |> Stream.iterate(&step/1)
    |> Stream.map(&count_flashes/1)
    |> Stream.take(101)
    |> Enum.sum
  end

  def all_flashed(map) do
    Map.values(map)
    |> Enum.all?(&(&1 == 0))
  end

  def second(input) do
    input
    |> Stream.iterate(&step/1)
    |> Enum.find_index(&all_flashed/1)
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

:timer.tc(Day11, :run, [])
|> elem(0)
|> div(1000)
|> then(&IO.puts("Runtime: #{&1}ms"))
