defmodule Day18 do
  def input do
    File.read!("input")
    # File.read!("test")
  end

  def to_tuple([a, b]), do: {to_tuple(a), to_tuple(b)}
  def to_tuple(a), do: a

  def parse_input(input) do
    input
    |> String.trim
    |> String.split("\n")
    |> Enum.map(&parse/1)
  end

  def parse(expr) do
    Code.eval_string(expr)
    |> elem(0)
    |> to_tuple
  end

  def label(level, label) do
    String.duplicate(" ", level * 2) <> label
  end

  def do_split({a, b}, %{split: false} = opt) do
    {res_a, opt_a} = do_split(a, opt)
    {res_b, opt_b} = do_split(b, opt_a)
    { {res_a, res_b}, opt_b }
  end

  def do_split(a, %{split: false} = opt) when a >= 10 do
    { { div(a, 2), div(a, 2) + Integer.mod(a, 2) }, %{split: true} }
  end

  def do_split(a, opt), do: { a, opt }

  def split(expr) do
    # IO.inspect(expr, label: "split")
    { new_expr, _ } = do_split(expr, %{split: false})
    if expr == new_expr do
      expr
    else
      reduce(new_expr)
    end
  end

  def add_left({a, b}, v), do: {a, add_left(b, v)}
  def add_left(a, v), do: a + v

  def explode(a, _level, %{right: right} = opt) when is_integer(a) do
    # IO.inspect({a, opt}, label: label(level, "int"))
    { a + right, Map.delete(opt, :right) }
  end

  def explode(a, _level, opt) when is_integer(a) do
    # IO.inspect({a, opt}, label: label(level, "int"))
    { a, opt }
  end

  def explode({a, b}, 4 = _level, %{exploded: false} = _opt) do
    # IO.inspect({a, b}, label: label(4, "terminal"))
    { 0, %{exploded: true, left: a, right: b} }
  end

  def explode({a, b}, level, opt) do
    # IO.inspect({{a, b}, level, opt}, label: label(level, "explode"))
    { res_a, opt_a } = explode(a, level + 1, opt)
                     # |> IO.inspect(label: label(level, "exploded a"))
    { res_b, opt_b } = explode(b, level + 1, Map.delete(opt_a, :left))
                     # |> IO.inspect(label: label(level, "exploded b"))
    cond do
      Map.has_key?(opt_a, :right) -> { { res_a, res_b }, Map.delete(opt_a, :right) }
      Map.has_key?(opt_b, :left) -> { { add_left(res_a, opt_b[:left]), res_b }, Map.delete(opt_b, :left) }
      true -> { { res_a, res_b }, Map.merge(opt_a, opt_b) }
    end
  end

  def reduce(expr) do
    # IO.inspect(expr, label: "reduce")
    { new_expr, _ } = explode(expr, 0, %{exploded: false})
    if expr == new_expr do
      split(new_expr)
    else
      reduce(new_expr)
    end
  end

  def magnitude({a, b}), do: magnitude(a) * 3 + magnitude(b) * 2

  def magnitude(a), do: a

  def add(expr_b, expr_a) do
    { expr_a, expr_b }
    |> reduce
  end

  def first(input) do
    input
    |> parse_input
    |> Enum.reduce(&add/2)
    |> magnitude
  end

  def second(input) do
    lines = input |> parse_input
    for x <- lines, y <- lines, x != y do
      [add(x, y) |> magnitude, add(y, x) |> magnitude]
    end
    |> List.flatten
    |> Enum.max
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

:timer.tc(Day18, :run, [])
|> elem(0)
|> div(1000)
|> then(&IO.puts("Runtime: #{&1}ms"))
