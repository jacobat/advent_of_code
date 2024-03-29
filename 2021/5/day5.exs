defmodule Day5 do
  @parser ~r/([0-9]+),([0-9]+) -> ([0-9]+),([0-9]+)/

  def input do
    File.read!("input")
    # File.read!("test")
    |> parse_line
  end

  def parse_line(string) do
    Regex.scan(@parser, string, capture: :all_but_first)
    |> List.flatten
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(2)
    |> Enum.chunk_every(2)
  end

  def diagonal?([[x0, y0], [x1, y1]]), do: x0 != x1 && y0 != y1

  def remove_diagonals(lines), do: Enum.reject(lines, &diagonal?/1)

  def line_to_cells([[x0, y0], [x1, y1]]) do
    cond do
      y0 == y1 -> for x <- x0..x1, do: {x, y0}
      x0 == x1 -> for y <- y0..y1, do: {x0, y}
      true -> Enum.zip(x0..x1, y0..y1)
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
