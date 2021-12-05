defmodule Day5 do
  def input do
    File.read!("input")
    # File.read!("test")
    |> String.split("\n")
    |> Enum.map(&parse_line/1)
  end

  def parse_line(string) do
    string
    |> String.split(" -> ")
    |> Enum.map(&parse_coord/1)
    |> Enum.sort
  end

  def parse_coord(string) do
    string
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def diagonal?([[x0, y0], [x1, y1]]), do: x0 != x1 && y0 != y1

  def remove_diagonals(lines), do: Enum.reject(lines, &diagonal?/1)

  def expand_diagonal([[x0, y0], [x1, y1]]) do
    if y0 < y1 do
      for x <- x0..x1, do: [x, y0 + x - x0]
    else
      for x <- x0..x1, do: [x, y0 - x + x0]
    end
  end

  def line_to_cells([[x0, y0], [x1, y1]] = line) do
    cond do
      y0 == y1 -> for x <- x0..x1, do: [x, y0]
      x0 == x1 -> for y <- y0..y1, do: [x0, y]
      true -> expand_diagonal(line)
    end
  end

  def count_overlaps(lines) do
    lines
    |> Enum.flat_map(&line_to_cells/1)
    |> Enum.frequencies
    |> Map.values
    |> Enum.count(&Kernel.>(&1, 1))
  end

  def first do
    input()
    |> remove_diagonals
    |> count_overlaps
  end

  def second do
    input()
    |> count_overlaps
  end

  def run do
    first() |> IO.inspect(limit: :infinity, label: "First")
    second() |> IO.inspect(limit: :infinity, label: "Second")
  end
end

Day5.run()
