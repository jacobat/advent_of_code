defmodule Day10 do
  def input do
    File.read!("input")
    # File.read!("test")
    |> String.trim
    |> String.split("\n")
  end

  def open(char, rest, stack), do: invalid_line?(rest, [char | stack])
  def close(char, rest, [char|stack]), do: invalid_line?(rest, stack)
  def close(char, _, _), do: {:corrupted, char}

  def invalid_line?("", stack), do: {:incomplete, stack}

  def invalid_line?(<<"]", rest::binary>>, stack), do: close("[", rest, stack)
  def invalid_line?(<<"}", rest::binary>>, stack), do: close("{", rest, stack)
  def invalid_line?(<<")", rest::binary>>, stack), do: close("(", rest, stack)
  def invalid_line?(<<">", rest::binary>>, stack), do: close("<", rest, stack)

  def invalid_line?(<<"[", rest::binary>>, stack), do: open("[", rest, stack)
  def invalid_line?(<<"{", rest::binary>>, stack), do: open("{", rest, stack)
  def invalid_line?(<<"(", rest::binary>>, stack), do: open("(", rest, stack)
  def invalid_line?(<<"<", rest::binary>>, stack), do: open("<", rest, stack)

  def invalid_line?(line) do
    invalid_line?(line, [])
  end

  def score("("), do: 3
  def score("["), do: 57
  def score("{"), do: 1197
  def score("<"), do: 25137

  def score_incomplete_char("("), do: 1
  def score_incomplete_char("["), do: 2
  def score_incomplete_char("{"), do: 3
  def score_incomplete_char("<"), do: 4

  def score_incomplete({:incomplete, rest}) do
    Enum.reduce(rest, 0, fn char, score ->
      score * 5 + score_incomplete_char(char)
    end)
  end

  def median(scores) do
    pos = Enum.count(scores) |> div(2)
    scores |> Enum.sort |> Enum.at(pos)
  end

  def map_lines(lines), do: Enum.map(lines, &invalid_line?/1)

  def first(input) do
    input
    |> map_lines
    |> Enum.filter(fn {l, _} -> l == :corrupted end)
    |> Enum.map(fn {_, c} -> score(c) end)
    |> Enum.sum
  end

  def second(input) do
    input
    |> map_lines
    |> Enum.filter(fn {l, _} -> l == :incomplete end)
    |> Enum.map(&score_incomplete/1)
    |> median
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

:timer.tc(Day10, :run, [])
|> elem(0)
|> div(1000)
|> then(&IO.puts("Runtime: #{&1}ms"))
