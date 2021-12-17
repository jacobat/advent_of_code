defmodule Day17 do
  def input do
    # [x0, x1, y0, y1] = "target area: x=20..30, y=-10..-5" |> parse
    [x0, x1, y0, y1] = "target area: x=211..232, y=-124..-69" |> parse
    {[x0, x1] |> Enum.sort, [y0, y1] |> Enum.sort}
  end

  def parse(string) do
    Regex.run(~r/x=(.*)\.\.(.*), y=(.*)\.\.(.*)/, string, capture: :all_but_first)
    |> Enum.map(&String.to_integer/1)
  end

  def max_height_for_velocity(y) do
    (y * (y + 1)) / 2 |> trunc
  end

  def min_x_velocity(x) do
    :math.sqrt(x) |> trunc
  end

  def in_target_area?(target_area, {x, y}) do
    [min_x, max_x] = elem(target_area, 0)
    [min_y, max_y] = elem(target_area, 1)
    x >= min_x && x <= max_x &&
      y >= min_y && y <= max_y
  end

  def hits_target?(target_area, x, y) do
    [_, max_x] = elem(target_area, 0)
    [min_y, _] = elem(target_area, 1)

    Stream.iterate({{0, 0}, {x, y}}, fn {{x_pos, y_pos}, {dx, dy}} ->
      ndx = if dx == 0, do: 0, else: dx - 1
      {{x_pos + dx, y_pos + dy}, {ndx, dy - 1}}
    end)
    |> Stream.map(&elem(&1, 0))
    |> Stream.take_while(fn {x, y} -> x <= max_x && y >= min_y end)
    |> Enum.find(&in_target_area?(target_area, &1))
  end

  def velocities(target_area) do
    x_min_velocity =
      target_area
      |> elem(0)
      |> Enum.min
      |> min_x_velocity
    x_max_velocity =
      target_area
      |> elem(0)
      |> Enum.max

    y_min_velocity =
      target_area
      |> elem(1)
      |> Enum.min
    y_max_velocity = 
      target_area
      |> elem(1)
      |> Enum.min
      |> abs
      |> Kernel.-(1)

    for x <- x_min_velocity..x_max_velocity,
      y <- y_min_velocity..y_max_velocity, hits_target?(target_area, x, y) do
      {x, y}
    end
  end

  def first(input) do
    input |> elem(1) |> Enum.min |> abs |> Kernel.-(1) |> max_height_for_velocity
  end

  def second(input) do
    input
    |> velocities
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

:timer.tc(Day17, :run, [])
|> elem(0)
|> div(1000)
|> then(&IO.puts("Runtime: #{&1}ms"))
