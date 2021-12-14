defmodule Day14 do
  def input do
    [polymer | [ _ | rules ]] = File.read!("input")
    # [polymer | [ _ | rules ]] = File.read!("test")
    |> String.trim
    |> String.split("\n")
    {
      polymer |> parse_polymer,
      rules |> parse_rules
    }
  end

  def parse_polymer(polymer) do
    polymer
    |> String.codepoints
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [a, b] -> {a, b} end)
  end

  def parse_rules(rules) do
    rules |> Enum.into(%{}, &parse_rule/1)
  end

  def parse_rule(rule) do
    [s, c] = rule |> String.split(" -> ")
    [a, b] = String.codepoints(s)
    { {a, b}, [{a, c}, {c, b}] }
  end

  def calc({min, max}), do: max - min

  def grow(freqs, rules) do
    freqs
    |> Enum.reduce(%{}, fn {pair, count}, acc ->
      rules[pair]
      |> Enum.reduce(acc, fn p, a -> Map.update(a, p, count, fn x -> x + count end) end)
    end)
  end

  def reduce_string(freqs) do
    freqs
    |> Enum.reduce(%{}, fn {{a, _}, cnt}, acc ->
      Map.update(acc, a, cnt, fn x -> x + cnt end)
    end)
  end

  def run({ polymer, rules }, steps) do
    last_char = List.last(polymer) |> elem(1)
    freqs = Enum.frequencies(polymer)
    Stream.iterate(freqs, &grow(&1, rules))
    |> Stream.drop(steps)
    |> Enum.take(1)
    |> List.first
    |> reduce_string
    |> Map.update!(last_char, fn n -> n + 1 end)
    |> Map.values
    |> Enum.min_max
    |> calc
  end

  def first(input) do
    run(input, 10)
  end

  def second(input) do
    run(input, 40)
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

:timer.tc(Day14, :run, [])
|> elem(0)
|> div(1000)
|> then(&IO.puts("Runtime: #{&1}ms"))
