defmodule Day13 do
  def input, do: File.read!("input")

  def parse_line(line) do
    [from, lg, point_string, to] = Regex.run(~r/(.*) would (gain|lose) (.*) happ.*to (.*)\./, line, capture: :all_but_first)

    points = point_string
             |> String.to_integer
             |> then(fn p ->
               if lg == "gain", do: p, else: -p
             end)
    { {from, to}, points }
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.into(%{})
  end

  def permutations(lst, acc \\ [])
  def permutations([l], acc) do
    first = List.last(acc)
    [[first | [l | acc]] |> Enum.reverse]
  end
  
  def permutations([head|rest], acc) do
    Enum.flat_map(rest, fn e ->
      permutations([e|List.delete(rest, e)], [head|acc])
    end)
  end

  def find_seatings(lst) do
    {
      lst
      |> Enum.map(&elem(&1, 0) |> elem(0))
      |> Enum.uniq
      |> permutations,
      lst
    }
  end

  def cost_it(permutation, costs) do
    permutation
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(&List.to_tuple/1)
    |> Enum.map(fn pair -> Map.get(costs, pair) end)
    |> Enum.sum
  end

  def cost_config(permutation, costs) do
    cost_it(permutation, costs) +
      cost_it(permutation |> Enum.reverse, costs)
  end

  def calculate_cost({permutations, costs}) do
    permutations
    |> Enum.map(&cost_config(&1, costs))
  end

  def add_me(input) do
    input
    |> Map.keys
    |> Enum.map(&elem(&1, 0))
    |> Enum.uniq
    |> Enum.flat_map(fn name ->
      [{{"Me", name}, 0}, {{name, "Me"}, 0}]
    end)
    |> Map.new
    |> Map.merge(input)
  end

  def first(input) do
    input
    |> parse
    |> find_seatings
    |> calculate_cost
    |> Enum.max
    # |> Enum.count
  end

  def second(input) do
    input
    |> parse
    |> add_me
    |> find_seatings
    |> calculate_cost
    |> Enum.max
  end

  def run() do
    with input <- input()
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

Day13.run()
