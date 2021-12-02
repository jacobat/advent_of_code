defmodule Day2 do
  def input do
    File.read!("input")
    |> String.split("\n")
  end

  def move("down " <> count, %{depth: depth, horizontal: _} = position) do
    %{position | depth: depth + String.to_integer(count) }
  end

  def move("up " <> count, %{depth: depth, horizontal: _} = position) do
    %{position | depth: depth - String.to_integer(count) }
  end

  def move("forward " <> count, %{depth: _, horizontal: horizontal} = position) do
    %{position | horizontal: horizontal + String.to_integer(count) }
  end

  def aim("down " <> count, %{depth: _, horizontal: _, aim: aim} = position) do
    %{position | aim: aim + String.to_integer(count) }
  end

  def aim("up " <> count, %{depth: _, horizontal: _, aim: aim} = position) do
    %{position | aim: aim - String.to_integer(count) }
  end

  def aim("forward " <> count, %{depth: depth, horizontal: horizontal, aim: aim} = position) do
    %{position | horizontal: horizontal + String.to_integer(count),
                 depth: depth + (String.to_integer(count) * aim) }
  end

  def calc(func) do
    %{depth: depth, horizontal: horizontal} =
      input()
      |> Enum.reduce(%{depth: 0, horizontal: 0, aim: 0}, func)
    horizontal * depth
  end

  def first do
    calc(&move/2)
  end

  def second do
    calc(&aim/2)
  end

  def run do
    first() |> IO.inspect(limit: :infinity, label: "First")
    second() |> IO.inspect(limit: :infinity, label: "Second")
  end
end

Day2.run()
