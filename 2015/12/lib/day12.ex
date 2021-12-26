defmodule Day12 do
  def input, do: File.read!("input")

  def first(input) do
    Regex.scan(~r/(-?[0-9]+)/, input, capture: :all_but_first)
    |> List.flatten
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum
  end

  def reject_red({_, v}) do
    reject_red(v)
  end

  def reject_red(m) when is_map(m) do
    if Map.values(m) |> Enum.member?("red") do
      []
    else
      m
      |> Map.map(&reject_red/1)
    end
  end

  def reject_red(m) when is_list(m) do
    Enum.map(m, &reject_red/1)
  end

  def reject_red(m) do
    m
  end

  def visit_all(tree, fun, acc) when is_list(tree) do
    Enum.reduce(tree, acc, fn subtree, acc2 -> visit_all(subtree, fun, acc2) end)
  end

  def visit_all(tree, fun, acc) when is_map(tree) do
    Enum.reduce(tree, acc, fn {_,v}, acc2 -> visit_all(v, fun, acc2) end)
  end

  def visit_all(tree, fun, acc) do
    if is_number(tree) do
      fun.(tree, acc)
    else
      acc
    end
  end

  def second(input) do
    input
    |> Jason.decode!
    |> reject_red
    |> visit_all(&Kernel.+/2, 0)
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

Day12.run()
