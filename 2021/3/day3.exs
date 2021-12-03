defmodule Day3 do
  def input do
    File.read!("input")
    # File.read!("test")
    |> String.split("\n")
    |> Enum.map(&String.codepoints/1)
  end

  def binary_to_int(bin_list) do
    Enum.join(bin_list) |> String.to_integer(2)
  end

  def binary_reverse_to_int(bin_list) do
    Enum.map(bin_list, fn s -> if s == "0", do: "1", else: "0" end)
    |> binary_to_int
  end

  def pick_more_frequent(%{"0" => zs, "1" => os}) when zs > os, do: "0"
  def pick_more_frequent(_), do: "1"

  def more_frequent(elements) do
    Enum.frequencies(elements) |> pick_more_frequent
  end

  def pick_less_frequent(%{"0" => zs, "1" => os}) when zs <= os, do: "0"
  def pick_less_frequent(_), do: "1"

  def less_frequent(elements) do
    Enum.frequencies(elements) |> pick_less_frequent
  end

  def first do
    gamma_bin = input()
                |> Enum.zip_reduce([], &[more_frequent(&1) | &2])
                |> Enum.reverse
    gamma = binary_to_int(gamma_bin)
    epsilon = binary_reverse_to_int(gamma_bin)
    gamma * epsilon
  end

  def rating([bin_list], _, _), do: binary_to_int(bin_list)

  def rating(list, index, fun) do
    rated = list |> Enum.map(&Enum.at(&1, index)) |> fun.()

    list
    |> Enum.filter(fn bin_list -> Enum.at(bin_list, index) == rated end)
    |> rating(index + 1, fun)
  end

  def second do
    rating(input(), 0, &more_frequent/1) *
      rating(input(), 0, &less_frequent/1)
  end

  def run do
    first() |> IO.inspect(limit: :infinity, label: "First")
    second() |> IO.inspect(limit: :infinity, label: "Second")
  end
end

Day3.run()
