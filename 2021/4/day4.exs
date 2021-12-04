defmodule Day4 do
  def input do
    File.read!("input")
    # File.read!("test")
    |> String.split("\n")
  end

  def numbers do
    input()
    |> List.first
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def parse_board(board) do
    rows = Enum.map(board, &Regex.scan(~r/[0-9]+/, &1) |> List.flatten |> Enum.map(fn x -> String.to_integer(x) end))
    cols = Enum.zip(rows) |> Enum.map(&Tuple.to_list/1)
    rows ++ cols
    |> Enum.map(&MapSet.new/1)
  end

  def boards do
    input()
    |> Enum.drop(2)
    |> Enum.reject(&(&1 == ""))
    |> Enum.chunk_every(5)
    |> Enum.map(&parse_board/1)
  end

  def win(numbers, board) do
    Enum.find(board, fn rowcol ->
      (MapSet.intersection(rowcol, numbers) == rowcol)
    end)
  end

  def numbers_to_win do
    Enum.reduce_while(numbers(), [], fn n, acc ->
      new_acc = [n | acc]
      if Enum.any?(boards(), &win(MapSet.new(new_acc), &1)) do
        {:halt, new_acc}
      else
        {:cont, new_acc}
      end
    end)
  end

  def winning_board(numbers) do
    Enum.find(boards(), &win(MapSet.new(numbers), &1))
  end

  def losing_board do
    Enum.reduce_while(numbers(), {[],boards()}, fn n, {ns,bs} ->
      new_ns = [n | ns]
      new_bs = Enum.reject(bs, fn board -> win(MapSet.new(new_ns), board) end)
      if Enum.count(bs) == 1 && win(MapSet.new(new_ns), List.first(bs)) do
        {:halt, {new_ns, List.first(bs)}}
      else
        {:cont, {new_ns, new_bs}}
      end
    end)
  end

  def unmarked_numbers(board, numbers) do
    Enum.reduce(board, &MapSet.union(&1, &2))
    |> MapSet.difference(MapSet.new(numbers))
  end

  def first do
    winning_board(numbers_to_win())
    |> unmarked_numbers(numbers_to_win())
    |> Enum.sum
    |> then(fn sum -> List.first(numbers_to_win()) * sum end)
  end

  def second do
    { numbers_drawn, board } = losing_board()
    unmarked_numbers(board, MapSet.new(numbers_drawn))
    |> Enum.sum
    |> then(fn sum -> List.first(numbers_drawn) * sum end)
  end

  def run do
    first() |> IO.inspect(limit: :infinity, label: "First")
    second() |> IO.inspect(limit: :infinity, label: "Second")
  end
end

Day4.run()
