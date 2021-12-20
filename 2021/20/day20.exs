defmodule Day20 do
  def input do
    File.read!("input")
    # File.read!("test")
  end

  def pixel_to_num(pixel) do
    if pixel == ".", do: 0, else: 1
  end

  def string_to_int(s) do
    s
    |> String.replace(".", "0")
    |> String.replace("#", "1")
  end

  def bench(fun, label) do
    t0 = DateTime.now!("Etc/UTC")
    result = fun.()
    t1 = DateTime.now!("Etc/UTC")
    DateTime.diff(t1, t0, :microsecond)
    |> IO.inspect(label: label)
    result
  end

  def transpose(rows), do: rows |> List.zip

  def int_to_key(int) do
    int
    |> Integer.to_string(2)
    |> String.pad_leading(9, "0")
    |> String.codepoints
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(3)
    |> transpose
  end

  def parse(input) do
    [img_enh_alg|img] = input
    |> String.split("\n", trim: true)

    image = img |> Enum.map(&string_to_int/1)
            |> Enum.map(fn s -> String.codepoints(s) |> Enum.map(fn s -> String.to_integer(s) end) end)

    algorithm = img_enh_alg
                |> String.codepoints
                |> Enum.with_index(fn pixel, num ->
                  %{ int_to_key(num) => pixel_to_num(pixel) }
                end)
                |> Enum.reduce(&Map.merge/2)

    {fn x -> Map.fetch!(algorithm, x) end, image}
  end

  def update_default(default, img_enh_alg) do
    default
    |> List.duplicate(9)
    |> Enum.chunk_every(3)
    |> Enum.map(&List.to_tuple/1)
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

  def map_chunks(enum, count, fun) do
    chunk_fun = fn element, acc ->
      if Enum.count(acc) == count - 1 do
        l = [element|acc]
        {:cont, fun.(Enum.reverse(l)), List.delete_at(l, -1)}
      else
        {:cont, [element|acc]}
      end
    end

    after_fun = fn _ -> {:cont, []} end
    Enum.chunk_while(enum, [], chunk_fun, after_fun)
  end

  def enhance_lines(lines, img_enh_alg) do
    lines
    |> Enum.zip
    |> map_chunks(3, img_enh_alg)
  end

  def enhance({image, default}, img_enh_alg) do
    new_image = grow_image(image, default)
                |> map_chunks(3, &enhance_lines(&1, img_enh_alg))
    { new_image, default |> update_default(img_enh_alg) }
  end

  def display({image, _default} = input) do
    image
    |> Enum.map(&Enum.join/1)
    |> Enum.join("\n")
    |> String.replace("0", ".")
    |> String.replace("1", "#")
    |> IO.puts
    input
  end

  def count_lit_pixels({image, _}) do
    Enum.map(image, fn line ->
      line
      |> Enum.sum
    end)
    |> Enum.sum
  end

  def run(input, iterations) do
    {img_enh_alg, image} = input |> parse
    {image, 0}
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
