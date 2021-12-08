defmodule Day8 do
  def input do
    File.read!("input")
    # File.read!("test")
    |> String.trim
    |> String.split("\n")
  end

  def first(input) do
    input
    |> Enum.flat_map(
      &String.split(&1, "|")
      |> List.last
      |> String.trim
      |> String.split
      |> Enum.map(fn s -> String.length(s) end)
    )
    |> Enum.count(&Enum.member?([2, 3, 4, 7], &1))
  end

  def find_digit(digits, segments_on), do: Enum.find(digits, &(Enum.count(&1) == segments_on))

  def digits_of_length(digits, segments_on), do: Enum.filter(digits, &(Enum.count(&1) == segments_on))

  def containing(digits, subdigit) do
    Enum.find(digits, &MapSet.subset?(subdigit, &1))
  end

  def contained_in(digits, superdigit) do
    Enum.find(digits, &MapSet.subset?(&1, superdigit))
  end

  def except(digits, subdigit) do
    Enum.reject(digits, &MapSet.subset?(subdigit, &1))
  end

  def digit_to_int(digit_map, digit), do: Map.get(digit_map, digit)

  def combine([a, b, c, d]), do: a * 1000 + b * 100 + c * 10 + d

  def process_line(line) do
    digits = line
             |> String.split("|")
             |> List.first
             |> String.trim
             |> String.split(" ")
             |> Enum.map(&String.codepoints(&1) |> MapSet.new)
             |> Enum.sort_by(&Enum.count/1)
    one = find_digit(digits, 2)
    seven = find_digit(digits, 3)
    four = find_digit(digits, 4)
    eight = find_digit(digits, 7)
    three = digits_of_length(digits, 5) |> containing(one)
    nine = digits_of_length(digits, 6) |> containing(three)
    zero = digits_of_length(digits, 6) |> except(nine) |> containing(one)
    six = digits_of_length(digits, 6) |> except(nine) |> except(zero) |> List.first
    five = digits_of_length(digits, 5) |> contained_in(six)
    two = digits_of_length(digits, 5) |> except(five) |> except(three) |> List.first
    digit_map = %{ zero => 0, one => 1, two =>  2, three =>  3, four =>  4, five =>  5, six =>  6, seven =>  7, eight =>  8, nine =>  9 }
    line
    |> String.split("|")
    |> List.last
    |> String.trim
    |> String.split(" ")
    |> Enum.map(&String.codepoints(&1) |> MapSet.new)
    |> Enum.map(&Map.get(digit_map, &1))
    |> combine
  end

  def second(input) do
    input |> Enum.map(&process_line/1)
    |> Enum.sum
  end

  def run do
    first(input()) |> IO.inspect(limit: :infinity, label: "First")
    second(input()) |> IO.inspect(limit: :infinity, label: "Second")
  end
end

Day8.run()
