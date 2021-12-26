defmodule Day14 do
  # def input, do: File.read!("test")
  def input, do: File.read!("input")

  def parse_line(line) do
    parts = String.split(line)
    name = Enum.at(parts, 0)
    speed = Enum.at(parts, 3) |> String.to_integer
    duration = Enum.at(parts, 6) |> String.to_integer
    rest = Enum.at(parts, 13) |> String.to_integer
    {name, %{speed: speed, duration: duration, rest: rest}}
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.into(%{})
  end

  def find_for({name, %{duration: duration, rest: rest, speed: speed}}, seconds) do
    count = Integer.floor_div(seconds, duration + rest)
    mod = Integer.mod(seconds, duration + rest)
    {min(mod, duration) * speed + count * speed * duration, name}
  end

  def find_at(input, seconds) do
    Enum.map(input, &find_for(&1, seconds))
  end

  def first(input) do
    input
    |> find_at(2503)
    |> Enum.map(&elem(&1, 0))
    |> Enum.max
  end

  def second(input) do
    (1..2503)
    |> Enum.reduce(%{}, fn second, acc ->
      scores = find_at(input, second)
      winning_score = scores |> Enum.max |> elem(0)
      Enum.filter(scores, fn {score, _} -> score == winning_score end)
      |> Enum.reduce(acc, fn {_, winner}, acc2 ->
        Map.update(acc2, winner, 1, &(&1 + 1))
      end)
    end)
    |> Enum.sort_by(&elem(&1, 1))
    |> List.last
    |> elem(1)
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

Day14.run()
