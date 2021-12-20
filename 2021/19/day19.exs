defmodule Day19 do
  def input do
    File.read!("input")
    # File.read!("test")
  end

  def parse_scanner(data) do
    [scanner | data] = String.split(data, "\n")
    { scanner, Enum.map(data, fn beacon -> beacon |> String.split(",") |> Enum.map(&String.to_integer/1) |> List.to_tuple end) }
  end

  def diff({x0, y0, z0}, {x1, y1, z1}) do
    { x1 - x0, y1 - y0, z1 - z0 }
  end

  def diff([x, y]), do: diff(x, y)

  def relatives(beacons) do
    beacons
    |> Enum.drop(11)
    |> Enum.map(fn origin ->
      beacons
      |> Enum.map(fn beacon -> %{beacon: beacon, relative: diff(beacon, origin)} end)
      |> MapSet.new
    end)
  end

  def relative_rotations({scanner, rotated_beacons}) do
    { scanner, rotated_beacons |> Enum.map(&relatives/1) }
  end

  def identity({x, y, z}), do: {x, y, z}
  def rotate_y_90({x, y, z}), do: {z, y, -x}
  def rotate_y_180(c), do: rotate_y_90(c) |> rotate_y_90
  def rotate_y_270(c), do: rotate_y_180(c) |> rotate_y_90
  def rotate_x_90({x, y, z}), do: {x, z, -y}
  def rotate_x_180(c), do: rotate_x_90(c) |> rotate_x_90
  def rotate_x_270(c), do: rotate_x_180(c) |> rotate_x_90
  def rotate_z_90({x, y, z}), do: {-y, x, z}
  def rotate_z_270(c), do: rotate_z_90(c) |> rotate_z_90 |> rotate_z_90

  def overlap?({d1, d2}) do
    d1r = d1 |> Enum.map(&(&1[:relative])) |> MapSet.new
    d2r = d2 |> Enum.map(&(&1[:relative])) |> MapSet.new
    12 <= MapSet.intersection(d1r, d2r) |> Enum.count
  end

  def add({x0, y0, z0}, {x1, y1, z1}), do: {x0 + x1, y0 + y1, z0 + z1}

  def translate_set(set, offset) do
    Enum.map(set, fn %{beacon: b} = s ->
      %{s | beacon: add(b, offset)}
    end)
    |> MapSet.new
  end

  def update_map({_, diff1, _}, {_, diff2}) do
    for d1 <- diff1, d2 <- diff2 do
      { d1, d2 }
    end
    |> Enum.find_value(fn { d1, d2s } ->
      match = Enum.find(d2s, fn d2 -> overlap?({d1, d2}) end)
      if match do
        matched_entry = match |> Enum.find(fn %{relative: r} ->
          Enum.any?(d1, fn %{relative: r2} -> r == r2 end)
            end)
        origin_entry = Enum.find(d1, fn %{relative: r} -> r == matched_entry[:relative] end)
        offset = diff(matched_entry[:beacon], origin_entry[:beacon])

        {offset, d2s |> Enum.map(&translate_set(&1, offset))}
      end
    end)
  end

  def find_overlapping({_, diff1, _}, {_, diff2}) do
    for d1 <- diff1, d2 <- diff2 do
      { d1, d2 }
    end
    |> Enum.find(fn { d1, d2s } ->
      Enum.any?(d2s, &overlap?({d1, &1}))
    end)
  end

  def rotations do
    [&identity/1, &rotate_x_90/1, &rotate_x_180/1,
      &rotate_x_270/1, &rotate_z_90/1, &rotate_z_270/1]
      |> Enum.flat_map(fn orientation ->
        [
          &identity/1,
          &rotate_y_90/1,
          &rotate_y_180/1,
          &rotate_y_270/1
        ]
        |> Enum.map(fn rotation ->
          fn c -> c |> orientation.() |> rotation.() end
        end)
      end)
  end

  def rotate({scanner, beacons}) do
    {scanner,
      Enum.map(rotations(), fn rotation ->
        Enum.map(beacons, rotation)
      end)
    }
  end

  def parse(input) do
    input
    |> String.split("\n\n")
    |> Enum.map(&parse_scanner/1)
  end

  def build_space(mapped, []), do: mapped

  def build_space(mapped, scanners) do
    overlapping_scanner = scanners |> Enum.find(&find_overlapping(mapped, &1))
    remaining_scanners = Enum.reject(scanners, &(&1 == overlapping_scanner))
    new_map = update_map(mapped, overlapping_scanner)
    offset = new_map |> elem(0)
    offsets = mapped |> elem(2)
    { "mapped", (mapped |> elem(1)) ++ (new_map |> elem(1)), [offset | offsets] }
    |> build_space(remaining_scanners)
  end

  def build_space(input) do
    [ scanner0 | rest ] = input |> parse
    scanner0_relatives = scanner0 |> elem(1) |> relatives
    sc0 = { scanner0 |> elem(0), scanner0_relatives, [{0, 0, 0}] }
    build_space(sc0, rest |> Enum.map(&rotate/1) |> Enum.map(&relative_rotations/1))
  end

  def manhattan_distance({x0, y0, z0}, {x1, y1, z1}) do
    abs(x1 - x0) + abs(y1 - y0) + abs(z1 - z0)
  end

  def first(input) do
    build_space(input)
    |> elem(1)
    |> Enum.flat_map(fn beacon_list ->
      Enum.map(beacon_list, &(&1[:beacon]))
    end)
    |> Enum.uniq
    |> Enum.count
  end

  def second(input) do
    space = build_space(input) |> elem(2) |> IO.inspect(label: "Offsets")
    for x <- space, y <- space do
      manhattan_distance(x, y)
    end
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

:timer.tc(Day19, :run, [])
|> elem(0)
|> div(1000)
|> then(&IO.puts("Runtime: #{&1}ms"))
