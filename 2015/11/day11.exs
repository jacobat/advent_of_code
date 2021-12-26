defmodule Day11 do
  def input, do: "hxbxwxba"

  def next(password) do
    password
    |> Enum.map(&(&1 - 97))
    |> Integer.undigits(26)
    |> Kernel.+(1)
    |> Integer.digits(26)
    |> Enum.map(&(&1 + 97))
  end

  def has_sequence?(password) do
    Enum.chunk_every(password, 3, 1, :discard)
    |> Enum.any?(fn [a, b, c] ->
      a + 1 == b && b + 1 == c
    end)
  end

  def no_invalid_letters?(password) do
    !(
    Enum.member?(password, 'i') ||
      Enum.member?(password, 'o') ||
        Enum.member?(password, 'l')
    )
  end

  def multiple_pairs?(password) do
    password
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.drop_while(fn [a, b] -> a != b end)
    |> Enum.drop(2)
    |> Enum.any?(fn [a, b] -> a == b end)
  end

  def valid?(password) do
    has_sequence?(password) &&
      no_invalid_letters?(password) &&
        multiple_pairs?(password)
  end

  def increment(password) do
    new_pw = next(password)
    if valid?(new_pw) do
      new_pw
    else
      increment(new_pw)
    end
  end

  def first(input) do
    input
    |> String.to_charlist
    |> increment
  end

  def second(input) do
    input |> increment
  end

  def run() do
    with input <- input()
    do
      first(input)
      |> IO.inspect(label: "First")
      |> second
      |> IO.inspect(label: "Second")
    end
  end
end

Day11.run()
