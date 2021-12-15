defmodule Day15 do
  @neighbour_offsets [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]

  def input do
    File.read!("input")
    # File.read!("test")
    |> String.trim
    |> String.split("\n")
    |> Enum.map(&String.codepoints/1)
    |> Enum.map(&Enum.with_index/1)
    |> Enum.with_index
    |> Enum.flat_map(fn {cols, row} ->
      Enum.map(cols, fn {value, col} ->
        {{col, row}, {value |> String.to_integer, :inf}}
      end)
    end)
    |> Enum.into(%{})
  end

  def neighbours(nodes, {x, y}) do
    Enum.map(@neighbour_offsets, fn {xo, yo} -> {x + xo, y + yo} end)
    |> then(fn n -> Map.take(nodes, n) end)
    |> Map.keys
  end

  def calculate_costs(neighbours, node_map, current_pos) do
    neighbours
    |> Enum.reduce(node_map, fn pos, acc ->
      current_cost = acc[current_pos] |> elem(1)
      total_cost = acc[pos] |> elem(1)
      cost = acc[pos] |> elem(0)
      if total_cost == :inf || cost + current_cost < total_cost do
        Map.put(acc, pos, {cost, cost + current_cost })
      else
        acc
      end
    end)
  end

  def shortest_path(nodes_remaining, [], _) do
    nodes_remaining
  end

  def shortest_path(nodes_remaining, [current_node | current_nodeset], visited) do
    neighbours = nodes_remaining |> neighbours(current_node) |> Enum.reject(fn node -> MapSet.member?(visited, node) end)
    new_map = neighbours |> calculate_costs(nodes_remaining, current_node)
    new_nodeset = (current_nodeset ++ neighbours)
                  |> Enum.uniq
                  |> Enum.sort_by(fn pos -> new_map[pos] |> elem(1) end)
    shortest_path(new_map, new_nodeset, MapSet.put(visited, current_node))
  end

  def shortest_path(input) do
    end_node = input |> Enum.sort |> List.last |> elem(0)
    input
    |> Map.update!({0, 0}, fn {v, :inf} -> {v, 0} end)
    |> shortest_path([{0, 0}], MapSet.new)
    |> Map.get(end_node)
    |> elem(1)
  end

  def wrap(v) when v > 9, do: v - 9
  def wrap(v), do: v

  def duplicate_map(input) do
    x_dim = (input |> Map.keys |> Enum.map(&elem(&1, 0)) |> Enum.max) + 1
    y_dim = (input |> Map.keys |> Enum.map(&elem(&1, 1)) |> Enum.max) + 1
    xed = for x <- 1..4 do
      Enum.map(input, fn {{x0, y0}, {risk, _}} ->
        {{x_dim * x + x0, y0}, {wrap(risk + x), :inf}}
      end)
      |> Enum.into(%{})
    end
    |> Enum.reduce(input, &Map.merge(&1, &2))
    for y <- 1..4 do
      Enum.map(xed, fn {{x0, y0}, {risk, _}} ->
        {{x0, y_dim * y + y0}, {wrap(risk + y), :inf}}
      end)
      |> Enum.into(%{})
    end
    |> Enum.reduce(xed, &Map.merge(&1, &2))
  end

  def first(input) do
    input |> shortest_path
  end

  def second(input) do
    input
    |> duplicate_map
    |> shortest_path
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

:timer.tc(Day15, :run, [])
|> elem(0)
|> div(1000)
|> then(&IO.puts("Runtime: #{&1}ms"))
