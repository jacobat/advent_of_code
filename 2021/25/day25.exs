defmodule Day25 do
  def input do
    File.read!("input")
    # File.read!("test")
    |> parse
  end

  def parse_line(line) do
    line
    |> String.codepoints
    # |> Enum.reject(&(&1 == "."))
  end

  def dimensions(input) do
    lines = input |> String.split("\n", trim: true)
    {
      lines |> List.first |> String.length,
      lines |> Enum.count
    }
  end

  def to_map({east_cukes, south_cukes}, input) do
    %{
      dimensions: dimensions(input),
      east: east_cukes |> Enum.map(&elem(&1, 0)) |> MapSet.new,
      south: south_cukes |> Enum.map(&elem(&1, 0)) |> MapSet.new
    }
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index
    |> Enum.flat_map(fn {line, row} ->
      parse_line(line)
      |> Enum.with_index
      |> Enum.map(fn {cell, col} ->
        {{col, row}, cell}
      end)
    end)
    |> Enum.reject(&elem(&1, 1) == ".")
    |> Enum.split_with(&elem(&1, 1) == ">")
    |> to_map(input)
  end

  def move(mapset, from, to) do
    mapset
    |> MapSet.delete(from)
    |> MapSet.put(to)
  end

  def step(map) do
    occupied_space = MapSet.union(map[:east], map[:south])
    new_east = map[:east]
    |> Enum.reduce(map[:east], fn {x, y}, east ->
      new_x = (x + 1) |> Integer.mod(elem(map[:dimensions], 0))
      to = {new_x, y}
      if MapSet.member?(occupied_space, to) do
        east
      else
        move(east, {x, y}, to)
      end
    end)
    occupied_space = MapSet.union(new_east, map[:south])
    new_south = map[:south]
    |> Enum.reduce(map[:south], fn {x, y}, south ->

      new_y = (y + 1) |> Integer.mod(elem(map[:dimensions], 1))
      to = {x, new_y}
      if MapSet.member?(occupied_space, to) do
        south
      else
        move(south, {x, y}, to)
      end
    end)
    %{map | east: new_east, south: new_south }
  end

  def display(%{dimensions: dimensions, east: east, south: south} = map) do
    for y <- 0..elem(dimensions, 1) - 1 do
      for x <- 0..elem(dimensions, 0) - 1 do
        cond do
          MapSet.member?(east, {x, y}) -> ">"
          MapSet.member?(south, {x, y}) -> "v"
          true -> "."
        end
      end
      |> Enum.join
      |> IO.puts
    end
    map
  end

  def display_with_index({map, index}) do
    IO.puts "After #{index} steps"
    display(map)
    IO.puts("")
  end

  def find_static(map, count) do
    # display_with_index({map, count})
    next_map = step(map)
    if map == next_map do
      count + 1
    else
      find_static(next_map, count + 1)
    end
  end

  def first(map) do
    map
    |> find_static(0)
    # |> Stream.iterate(&step/1)
    # |> Stream.drop(56)
    # |> Enum.take(4)
    # |> Enum.chunk_every(2, 1, :discard)
    # |> Enum.map(fn [x, y] -> x == y end)
  end

  def second(_input) do
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

IO.puts("")
IO.puts("***************************")
IO.puts("******** New run **********")
IO.puts("***************************")
IO.puts("")


:timer.tc(Day25, :run, [])
|> elem(0)
|> div(1000)
|> then(&IO.puts("Runtime: #{&1}ms"))
