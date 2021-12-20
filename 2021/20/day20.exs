defmodule Day20 do
  def input do
    File.read!("input")
    # File.read!("test")
  end

  def pixel_to_num(pixel) do
    if pixel == ".", do: "0", else: "1"
  end

  def string_to_int(s) do
    s
    |> String.replace(".", "0")
    |> String.replace("#", "1")
  end

  def transpose(rows), do: rows |> List.zip

  def int_to_key(int) do
    int
    |> Integer.to_string(2)
    |> String.pad_leading(9, "0")
    |> String.codepoints
    |> Enum.chunk_every(3)
    |> transpose
  end

  def parse(input) do
    [img_enh_alg|img] = input
    |> String.split("\n", trim: true)

    image = img |> Enum.map(&string_to_int/1)
            |> Enum.map(&String.codepoints/1)

    algorithm = img_enh_alg
                |> String.codepoints
                |> Enum.with_index(fn pixel, num ->
                  %{ int_to_key(num) => pixel_to_num(pixel) }
                end)
                |> Enum.reduce(&Map.merge/2)

    {fn x -> Map.get(algorithm, x, :miss) end, image}
  end

  def dimensions(image, elem) do
    Map.keys(image)
    |> Enum.map(&elem(&1, elem))
    |> Enum.min_max
  end

  def dimensions(image) do
    [
      {0, (List.first(image) |> Enum.count) - 1},
      {0, Enum.count(image) - 1}
    ]
  end

  def window_to_number(window) do
    window
    |> Enum.join
    |> String.to_integer(2)
  end

  def neighbours(lines, {x, _y}) do
    Enum.slice(lines, x + 2 - 1, 3)
  end

  def update_default(default, img_enh_alg) do
    default
    |> List.duplicate(9)
    |> Enum.chunk_every(3)
    |> Enum.map(&List.to_tuple/1)
    |> img_enh_alg.()
  end

  def enhance_pixel(lines, {x, y}, img_enh_alg) do
    neighbours(lines, {x, y})
    |> img_enh_alg.()
  end

  def grow_image(image, default) do
    default_line = List.duplicate(default, (Enum.at(image, 0) |> Enum.count) + 4)
    [ default_line, default_line ] ++
      Enum.map(image, fn line ->
        List.duplicate(default, 2) ++ line ++ List.duplicate(default, 2)
      end) ++
        [ default_line, default_line ]
  end

  def bench(fun, label) do
    t0 = DateTime.now!("Etc/UTC")
    result = fun.()
    t1 = DateTime.now!("Etc/UTC")
    DateTime.diff(t1, t0, :microsecond)
    |> IO.inspect(label: label)
    result
  end

  def enhance({image, default}, img_enh_alg) do
    [{x_min, x_max}, {y_min, y_max}] = dimensions(image)

    padded_image = grow_image(image, default)
    new_image = for y <- (y_min - 1)..(y_max + 1) do
      lines = Enum.slice(padded_image, y - 1 + 2, 3)
              |> Enum.zip

      for x <- (x_min - 1)..(x_max + 1), into: [] do
        enhance_pixel(lines, {x, y}, img_enh_alg)
      end
    end
    { new_image, default |> update_default(img_enh_alg) }
  end

  def display({image, default} = input) do
    [{x_min, x_max}, {y_min, y_max}] = dimensions(image)
    for y <- (y_min - 2)..(y_max + 2) do
      for x <- (x_min - 2)..(x_max + 2) do
        if Map.get(image, {x, y}, default) == "1", do: "#", else: "."
      end
      |> Enum.join
      |> IO.puts
    end
    input
  end

  def count_lit_pixels({image, _}) do
    Enum.map(image, fn line ->
      # String.codepoints(line)
      line
      |> Enum.map(&String.to_integer/1)
      |> Enum.sum
    end)
    |> Enum.sum
  end

  def run(input, iterations) do
    {img_enh_alg, image} = input |> parse
    {image, "0"}
    # |> enhance(img_enh_alg)
    |> Stream.iterate(&enhance(&1, img_enh_alg))
    |> Stream.drop(iterations)
    |> Enum.take(1)
    |> List.first
    # # |> display
    |> count_lit_pixels
  end

  def first(input) do
    run(input, 2)
  end

  def second(input) do
    run(input, 50)
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

:timer.tc(Day20, :run, [])
|> elem(0)
|> div(1000)
|> then(&IO.puts("Runtime: #{&1}ms"))
