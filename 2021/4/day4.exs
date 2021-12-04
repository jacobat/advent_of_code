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
      MapSet.intersection(rowcol, numbers) == rowcol
    end)
  end

  def find_board(remaining_losing_boards) do
    Enum.reduce_while(numbers(), {[],boards()}, fn n, {ns,bs} ->
      new_ns = [n | ns]
      { winning_boards, losing_boards } = Enum.split_with(bs, &win(MapSet.new(new_ns), &1))
      if Enum.count(losing_boards) == remaining_losing_boards do
        {:halt, {new_ns, List.first(winning_boards)}}
      else
        {:cont, {new_ns, losing_boards}}
      end
    end)
  end

  def unmarked_numbers(board, numbers) do
    Enum.reduce(board, &MapSet.union(&1, &2))
    |> MapSet.difference(MapSet.new(numbers))
  end

  def calc_score({ numbers_drawn, board }) do
    unmarked_numbers(board, MapSet.new(numbers_drawn))
    |> Enum.sum
    |> then(fn sum -> List.first(numbers_drawn) * sum end)
  end

  def first do
    find_board(Enum.count(boards()) - 1) |> calc_score
  end

  def second do
    find_board(0) |> calc_score
  end

  def run do
    first() |> IO.inspect(limit: :infinity, label: "First")
    second() |> IO.inspect(limit: :infinity, label: "Second")
  end
end

Day4.run()
