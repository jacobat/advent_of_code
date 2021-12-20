defmodule Day20 do
  def input do
    File.read!("input")
    # File.read!("test")
  end

  def pixel_to_num(pixel) do
    if pixel == ".", do: "0", else: "1"
  end

  def parse(input) do
    [img_enh_alg|img] = input
    |> String.split("\n", trim: true)

    image =
      img
      |> Enum.with_index(fn line, row ->
        line
        |> String.codepoints
        |> Enum.map(&pixel_to_num/1)
        |> Enum.with_index(fn pixel, col ->
          %{{col, row} => pixel}
        end)
      |> Enum.reduce(&Map.merge/2)
    end)
    |> Enum.reduce(&Map.merge/2)

    algorithm = img_enh_alg
                |> String.codepoints
                |> Enum.with_index(fn pixel, index ->
                  binary = Integer.to_string(index, 2)
                  |> String.pad_leading(9, "0")
                  |> String.codepoints
                  %{ binary => pixel |> pixel_to_num }
                end)
                |> Enum.reduce(&Map.merge/2)

    {fn x -> Map.get(algorithm, x) end, image}
  end

  def dimensions(image, elem) do
    Map.keys(image)
    |> Enum.map(&elem(&1, elem))
    |> Enum.min_max
  end

  def dimensions(image) do
    [
      dimensions(image, 0),
      dimensions(image, 1)
    ]
  end

  def window_to_number(window) do
    window
    |> Enum.join
    |> String.to_integer(2)
  end

  def neighbours(image, {x, y}, default) do
    for y0 <- (y - 1)..(y + 1), x0 <- (x - 1)..(x + 1) do
      Map.get(image, {x0, y0}, default)
    end
  end

  def enhance(image, {x, y}, img_enh_alg, default) do
    neighbours(image, {x, y}, default)
    |> img_enh_alg.()
  end

  def update_default(default, img_enh_alg) do
    default
    |> List.duplicate(9)
    |> img_enh_alg.()
  end

  def enhance({image, default}, img_enh_alg) do
    [{x_min, x_max}, {y_min, y_max}] = dimensions(image)
    new_image = for y <- (y_min - 2)..(y_max + 2),
      x <- (x_min - 2)..(x_max + 2),
      into: %{} do
        {{x, y}, enhance(image, {x, y}, img_enh_alg, default)}
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
    Map.values(image)
    |> Enum.frequencies
    |> Map.get("1")
  end

  def run(input, iterations) do
    {img_enh_alg, image} = input |> parse
    {image, "0"}
    |> Stream.iterate(&enhance(&1, img_enh_alg))
    |> Stream.drop(iterations)
    |> Enum.take(1)
    |> List.first
    # |> display
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
