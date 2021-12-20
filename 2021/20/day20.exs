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

  def parse(input) do
    [img_enh_alg|img] = input
    |> String.split("\n", trim: true)

    image = img
            |> Enum.map(&string_to_int/1)
    #   img
    #   |> Enum.with_index(fn line, row ->
    #     line
    #     |> String.codepoints
    #     |> Enum.map(&pixel_to_num/1)
    #     |> Enum.with_index(fn pixel, col ->
    #       %{{col, row} => pixel}
    #     end)
    #   |> Enum.reduce(&Map.merge/2)
    # end)
    # |> Enum.reduce(&Map.merge/2)

    algorithm = img_enh_alg
                |> String.codepoints
                |> Enum.with_index(fn pixel, index ->
                  binary = Integer.to_string(index, 2)
                  |> String.pad_leading(9, "0")
                  # |> String.codepoints
                  # |> Enum.chunk_every(3)
                  # |> Enum.map(&Enum.join/1)
                  %{ binary => pixel |> pixel_to_num }
                end)
                |> Enum.reduce(&Map.merge/2)
                # |> IO.inspect(label: "Alg")


    {fn x -> Map.get(algorithm, x) end, image}
  end

  def dimensions(image, elem) do
    Map.keys(image)
    |> Enum.map(&elem(&1, elem))
    |> Enum.min_max
  end

  def dimensions(image) do
    [
      {0, (List.first(image) |> String.length) - 1},
      {0, Enum.count(image) - 1}
    ]
  end

  def window_to_number(window) do
    window
    |> Enum.join
    |> String.to_integer(2)
  end

  def neighbours(lines, {x, y}) do
    # IO.inspect({x, y}, label: "Image for n #{x}, #{y}")
    slices = Enum.map(lines, fn line ->
      # line = bench(fn -> Enum.at(image, y0 + 2) end, "at")
      # Enum.at(image, y0 + 2)
             # |> IO.inspect(label: "Line")

      # bench(fn -> String.slice(line, x + 2 - 1, 3) end, "slice")# |> IO.inspect(label: "Neighbours")
      String.slice(line, x + 2 - 1, 3)
      # Map.get(image, {x0, y0}, default)
    end)
    # bench(fn -> Enum.join(slices) end, "join")
    Enum.join(slices)
  end

  def update_default(default, img_enh_alg) do
    default
    |> String.duplicate(9)
    # |> List.duplicate(3)
    |> img_enh_alg.()
  end

  def enhance_pixel(lines, {x, y}, img_enh_alg) do
    # ns = bench(fn -> neighbours(lines, {x, y}) end, "neighbours #{x}, #{y}")
    ns = neighbours(lines, {x, y})
    # |> IO.inspect(label: "Neighbours")
    img_enh_alg.(ns)
  end

  def grow_image(image, default) do
    default_line = String.duplicate(default, (Enum.at(image, 0) |> String.length) + 4)
    [ default_line, default_line ] ++
      Enum.map(image, fn line ->
        String.duplicate(default, 2) <> line <> String.duplicate(default, 2)
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

    # padded_image = bench(fn -> grow_image(image, default) end, "Grow image")
    padded_image = grow_image(image, default)
    new_image = for y <- (y_min - 1)..(y_max + 1) do
      lines = Enum.slice(padded_image, y - 1 + 2, 3)
      for x <- (x_min - 1)..(x_max + 1), into: "" do
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
      String.codepoints(line)
      |> Enum.map(&String.to_integer/1)
      |> Enum.sum
    end)
    |> Enum.sum
    # Map.values(image)
    # |> Enum.frequencies
    # |> Map.get("1")
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
