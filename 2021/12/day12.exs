defmodule Day12 do
  def input do
    File.read!("input")
    # File.read!("test1")
    # File.read!("test2")
    # File.read!("test3")
    |> String.trim
    |> String.split("\n")
    |> Enum.map(&parse/1)
  end

  def parse(string) do
    String.split(string, "-")
    |> Enum.map(&parse_cave/1)
    |> Enum.sort_by(fn {_, s} -> if s == :start, do: 0, else: 1 end)
  end

  def parse_cave(s) do
    cond do
      s == "start" -> { s, :start }
      s == "end" -> { s, :end }
      Regex.match?(~r/[a-z]+/, s) -> { s, :once }
      true -> { s, :many }
    end
  end

  def double_once?(path) do
    path
    |> Enum.filter(fn {_, type} -> type == :once end)
    |> Enum.frequencies
    |> Map.values
    |> Enum.any?(&(&1 > 1))
  end

  def stringify(lst) do
    lst
    |> Enum.map(&elem(&1,0))
    |> Enum.join(",")
  end

  def connection_for_node?([n1, n2], node) do
    n1 == node || n2 == node
  end

  def order_nodes([n1, n2], current_node) do
    if n1 == current_node do
      [n1, n2]
    else
      [n2, n1]
    end
  end

  def filter_graph(graph) do
    graph
    |> Enum.reject(fn [{_, type}, _] -> type == :start end)
  end

  def render_conn(connections) do
    connections
    |> Enum.map(fn [{n1, _}, {n2, _}] -> n1 <> " - " <> n2 end)
    |> Enum.join(", ")
  end

  def filter_visited(graph, current_node, path, revisit) do
    if (double_once?([current_node | path]) || !revisit) do
      graph
      |> Enum.reject(fn [{_, st} = s, {_, et} = e] ->
        if s == current_node do
          Enum.member?(path, e) && et == :once
        else
          Enum.member?(path, s) && st == :once
        end
      end)
    else
      graph
    end
  end

  def possible_connections(graph, current_node, path, revisit) do
    graph
    |> Enum.filter(&connection_for_node?(&1, current_node))
    |> filter_visited(current_node, path, revisit)
  end

  def search(_, {_, :end} = node, path, _), do: [[node | path] |> Enum.reverse]
  def search([], _, _, _), do: nil

  def search(graph, current_node, path, revisit) do
    new_graph = filter_graph(graph)
    graph
    |> possible_connections(current_node, path, revisit)
    |> Enum.map(&order_nodes(&1, current_node))
    |> Enum.flat_map(fn [_, next_node] ->
      search(new_graph, next_node, [current_node | path], revisit)
    end)
  end

  def search(graph, current_node, revisit), do: search(graph, current_node, [], revisit)

  def first(input) do
    input
    |> search({"start", :start}, false)
    |> Enum.map(&stringify/1)
    |> Enum.count
  end

  def second(input) do
    input
    |> search({"start", :start}, true)
    |> Enum.map(&stringify/1)
    |> Enum.count
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

:timer.tc(Day12, :run, [])
|> elem(0)
|> div(1000)
|> then(&IO.puts("Runtime: #{&1}ms"))
