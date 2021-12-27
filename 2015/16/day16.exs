defmodule Day16 do
  # def input, do: File.read!("test")
  def input, do: File.read!("input")

  def ticker do
    """
    children: 3
    cats: 7
    samoyeds: 2
    pomeranians: 3
    akitas: 0
    vizslas: 0
    goldfish: 5
    trees: 3
    cars: 2
    perfumes: 1
    """
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_compound/1)
    |> Map.new
  end

  def parse_compound(c) do
    [name, count] = c |> String.split(": ")
    { name, String.to_integer(count) }
  end

  def parse_line(line) do
    [sue, compounds] = String.split(line, ": ", parts: 2)
    number = String.replace(sue, "Sue ", "") |> String.to_integer
    parts = String.split(compounds, ", ")
            |> Enum.map(&parse_compound/1)
    {number, Map.new(parts)}
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.into(%{})
  end

  def match_option?(option, ticker) do
    Enum.all?(option, fn {name, count} ->
      Map.get(ticker, name) == count
    end)
  end

  def match_ranged_option?(option, ticker) do
    Enum.all?(option, fn {name, count} ->
      ticker_count = Map.get(ticker, name)
      case name do
        "cats" -> count > ticker_count
        "trees" -> count > ticker_count
        "pomeranians" -> count < ticker_count
        "goldfish" -> count < ticker_count
        _ -> count == ticker_count
      end
    end)
  end

  def find_match(input, ticker, matcher) do
    input
    |> Enum.find(fn {_, option} -> matcher.(option, ticker) end)
  end

  def first(input) do
    input
    |> find_match(ticker(), &match_option?/2)
    |> elem(0)
  end

  def second(input) do
    input
    |> find_match(ticker(), &match_ranged_option?/2)
    |> elem(0)
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

Day16.run()
