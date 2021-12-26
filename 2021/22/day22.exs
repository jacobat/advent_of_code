defmodule Day22 do
  @scanner ~r/(on|off) x=(.*)\.\.(.*),y=(.*)\.\.(.*),z=(.*)\.\.(.*)/

  def input do
    File.read!("input")
    # File.read!("test2")
    # File.read!("test1")
    |> parse
  end

  def parse_line(line) do
    [state | coords] = Regex.run(@scanner, line, capture: :all_but_first)
    coords
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(2)
    |> Enum.map(fn [x, y] -> Range.new(x, y) end)
    |> then(fn x -> { state, x } end)
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  def disjoint?([x0, y0, z0], [x1, y1, z1]) do
    Range.disjoint?(x0, x1) ||
      Range.disjoint?(y0, y1) ||
        Range.disjoint?(z0, z1)
  end

  def split_with([x0..x1, y0..y1, z0..z1] = c1, [xx0..xx1, yy0..yy1, zz0..zz1] = c2) do
    # IO.inspect([c1, c2], label: "split with")
    cond do
      disjoint?(c1, c2) -> [c2]
      xx0 < x0 -> split_cube_list([c1, [xx0..x0-1, yy0..yy1, zz0..zz1], [x0..xx1, yy0..yy1, zz0..zz1]])
      xx1 > x1 -> split_cube_list([c1, [x1+1..xx1, yy0..yy1, zz0..zz1], [xx0..x1, yy0..yy1, zz0..zz1]])
      yy0 < y0 -> split_cube_list([c1, [xx0..xx1, yy0..y0-1, zz0..zz1], [xx0..xx1, y0..yy1, zz0..zz1]])
      yy1 > y1 -> split_cube_list([c1, [xx0..xx1, yy0..y1, zz0..zz1], [xx0..xx1, y1+1..yy1, zz0..zz1]])
      zz0 < z0 -> split_cube_list([c1, [xx0..xx1, yy0..yy1, zz0..z0-1], [xx0..xx1, yy0..yy1, z0..zz1]])
      zz1 > z1 -> split_cube_list([c1, [xx0..xx1, yy0..yy1, zz0..z1], [xx0..xx1, yy0..yy1, z1+1..zz1]])
      true -> []
    end
  end

  def split_cube_list([head|cubes]) do
    # IO.inspect([head|cubes], label: "split cube list")
    Enum.flat_map(cubes, fn cube ->
      split_with(head, cube)
    end)
  end

  def split_cubes([head|_] = l), do: [head|split_cube_list(l)]

  def flip_cube({"off", [xs, ys, zs]}, cubes) do
    for x <- xs, y <- ys, z <- zs, reduce: cubes do
      acc -> Map.delete(acc, {x, y, z})
    end
  end

  def flip_cube({"on", [xs, ys, zs]}, cubes) do
    for x <- xs, y <- ys, z <- zs, reduce: cubes do
      acc -> Map.put(acc, {x, y, z}, 1)
    end
  end

  def flip_cubes(list, cubes) do
    Enum.reduce(list, cubes, fn line, acc ->
      flip_cube(line, acc)
    end)
  end

  def process_cubes([], acc), do: acc

  def process_cubes([head|list], acc) do
    # IO.inspect(Enum.count(list), label: "Processing")
    {state, cube} = head
    if state == "on" do
      process_cubes(list, split_cubes([cube|acc]))
    else
      [_|l] = split_cubes([cube|acc])
      process_cubes(list, l)
    end
  end

  def crop_range(x0..y0, lower..upper) do
    Range.new(Enum.max([x0, lower]), Enum.min([y0, upper]))
  end

  def crop_cube({state, [xs, ys, zs]}) do
    limits = -50..50
    if Range.disjoint?(xs, limits) || Range.disjoint?(ys, limits) || Range.disjoint?(zs, limits) do
      # IO.puts "Disjoint"
      nil
    else
      {state, [crop_range(xs, limits), crop_range(ys, limits), crop_range(zs, limits)]}
    end
  end

  def crop_cubes(list) do
    Enum.map(list, &crop_cube/1)
    |> Enum.reject(&Kernel.is_nil/1)
  end

  def cube_size([x0..x1, y0..y1, z0..z1]) do
    (x1 - x0 + 1) * (y1 - y0 + 1) * (z1 - z0 + 1)
  end

  def sum_cubes(cubes) do
    Enum.map(cubes, &cube_size/1)
    |> Enum.sum
  end

  def first(input) do
    input
    |> crop_cubes
    # |> Enum.take(2)
    |> process_cubes([])
    # |> IO.inspect(label: "Processed")
    |> sum_cubes
    # |> Enum.reduce([], &split_cubes/2)
    # |> IO.inspect
    # |> flip_cubes(%{})
    # |> Enum.count
  end

  def second(input) do
    input
    |> process_cubes([])
    |> sum_cubes
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


# Day22.split_cubes([[10..12, 10..12, 10..12], [11..13, 11..13, 11..13]])
# |> IO.inspect
# Day22.split_cubes([[11..13, 11..13, 11..13], [10..12, 10..12, 10..12]])
# |> IO.inspect
# Day22.split_cubes([[9..13, 9..13, 9..13], [10..12, 10..12, 10..12]])
# |> IO.inspect
# Day22.split_cubes([[10..12, 10..12, 10..12], [9..13, 9..13, 9..13]])
# |> IO.inspect
:timer.tc(Day22, :run, [])
|> elem(0)
|> div(1000)
|> then(&IO.puts("Runtime: #{&1}ms"))
