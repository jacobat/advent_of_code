defmodule Day23 do
  def data do
    """
    #############
    #...........#
    ###D#B#A#C###
      #B#D#A#C#
      #########
    """
  end

  def data2 do
    """
    #############
    #...........#
    ###D#B#A#C###
      #D#C#B#A#
      #D#B#A#C#
      #B#D#A#C#
      #########
    """
  end

  def test do
    """
    #############
    #...........#
    ###B#C#B#D###
      #A#D#C#A#
      #########
    """
  end

  def test2 do
    """
    #############
    #...........#
    ###B#C#B#D###
      #D#C#B#A#
      #D#B#A#C#
      #A#D#C#A#
      #########
    """
  end

  def input do
    data2()
  end

  def parse_map(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.drop(2)
    # |> Enum.take(2)
    |> Enum.map(&Regex.scan(~r/([A-D])/, &1, capture: :all_but_first))
    |> Enum.with_index
    |> Enum.flat_map(fn {row, row_idx} ->
      row
      |> Enum.with_index
      |> Enum.map(fn {[cell], col_idx} ->
        {{col_idx * 2 + 2, row_idx + 1}, cell}
      end)
    end)
    |> Enum.into(%{})
    |> Map.merge(%{
      {0, 0} => nil,
      {1, 0} => nil,
      {3, 0} => nil,
      {5, 0} => nil,
      {7, 0} => nil,
      {9, 0} => nil,
      {10, 0} => nil
    })
  end

  def piece_in_room?({{x, _}, _}) do
    Enum.member?([2, 4, 6, 8], x)
  end

  def room_empty?(map, col) do
    !Enum.any?(map, fn {{x, _}, c} -> x == col && c != nil end)
  end

  def can_move_to_room?(map, piece) do
    target_for_piece(piece)
    |> then(&room_empty?(map, &1))
  end

  def room_target(map, piece) do
    [
      target_for_piece(piece)
      |> then(&bottom_element(map, &1))
    ]
  end

  def available_staging_targets(map) do
    Enum.filter(map, fn {{_, y}, v} -> y == 0 && v == nil end)
  end

  def clear_path?(map, {{x0, _}, _}, {{x1, _}, _}) do
    # IO.inspect({map, x0, x1}, label: "Clear path")
    !Enum.any?(map, fn {{x, y}, v} -> y == 0 && x > min(x0,x1) && x < max(x0,x1) && v != nil end)
    # |> IO.inspect(label: "Clear path result")
  end

  def staging_targets(map) do
    available_staging_targets(map)
  end

  def possible_targets(map, piece) do
    # IO.inspect(piece, label: "Possible targets")
    # display(map)
    cond do
      can_move_to_room?(map, piece) -> room_target(map, piece)
      piece_in_room?(piece) -> staging_targets(map)
      true -> []
    end
  end

  def cost_for(letter) do
    case letter do
      "A" -> 1
      "B" -> 10
      "C" -> 100
      "D" -> 1000
      _ -> raise "What?"
    end
  end

  def with_cost({{x0, y0}, _} = target, {{x1, y1}, v}) do
    # IO.inspect({target, x1, y1}, label: "Cost")
    {target, (abs(x1 - x0) + y1 + y0) * cost_for(v)}
  end

  def perform_move(map, {{x0, y0}, v0}, {{{x1, y1}, nil}, move_cost}, cost) do
    new_map =
      map
      |> Map.replace!({x1, y1}, v0)
      |> Map.replace!({x0, y0}, nil)
      |> then(fn m ->
        if y1 > 0 do
          eliminate_correct_pieces(m)
        else
          m
        end
      end)
    { new_map, cost + move_cost }
  end

  def move(map, piece, cost, best_cost) do
    possible_targets(map, piece)
    # |> IO.inspect(label: "Possible targets")
    |> Enum.filter(fn target -> clear_path?(map, piece, target) end)
    # |> IO.inspect(label: "Filtered targets")
    |> Enum.map(&with_cost(&1, piece))
    |> Enum.sort_by(&elem(&1, 1))
    # |> IO.inspect(label: "Ready to move")
    |> Enum.map(&perform_move(map, piece, &1, cost))
    |> Enum.reduce(best_cost, fn v, acc ->
      min(acc, find_valid_solutions(v, acc))
    end)
    # |> IO.inspect("Done with move")
  end

  def find_valid_solutions({map, cost}, best_cost) do
    # IO.inspect(best_cost, label: "Best cost")
    if cost >= best_cost do
      best_cost
    else
      moveable_pieces = map
      # |> display(cost)
      |> movable_pieces
      if Enum.count(moveable_pieces) == 0 do
        # IO.puts "Found solution #{cost}"
        # display(map, cost)
        if best_cost == nil do
          cost
        else
          min(cost, best_cost)
        end
      else
        moveable_pieces
        |> Enum.reduce(best_cost, fn piece, acc ->
          move(map, piece, cost, acc)
        end)
      end
    end
  end

  def find_solutions(map, cost), do: find_valid_solutions({map, cost}, nil)

  def target_for_piece({_, letter}) do
    case letter do
      "A" -> 2
      "B" -> 4
      "C" -> 6
      "D" -> 8
      _ -> raise "What?"
    end
  end

  def letter_for_target(x) do
    case x do
      2 -> "A"
      4 -> "B"
      6 -> "C"
      8 -> "D"
      _ -> raise "What?"
    end
  end

  def bottom_element(map, col) do
    Enum.filter(map, fn {{x, _}, _} -> x == col end)
    |> Enum.sort
    |> Enum.reverse
    |> List.first
  end

  def eliminate_correct_pieces(map) do
    for x <- [2, 4, 6, 8], reduce: map do
      acc ->
        be = bottom_element(acc, x)
        if be == nil do
          acc
        else
          {pos, value} = bottom_element(acc, x)
          if value == (letter_for_target(x)) do
            Map.delete(acc, pos)
          else
            acc
          end
        end
    end
  end

  def stack_0_peak(map) do
    if Map.get(map, {1, 0}) == nil do
      {{0, 0}, Map.get(map, {0, 0})}
    else
      {{1, 0}, Map.get(map, {1, 0})}
    end
  end

  def stack_1_peak(map) do
    if Map.get(map, {9, 0}) == nil do
      {{10, 0}, Map.get(map, {10, 0})}
    else
      {{9, 0}, Map.get(map, {9, 0})}
    end
  end

  def stack_peak(map, col) do
    Enum.filter(map, fn {{x, _}, v} -> x == col && v != nil end)
    |> Enum.sort
    |> List.first
  end

  def movable_pieces(map) do
    [
      stack_peak(map, 2),
      stack_peak(map, 4),
      stack_peak(map, 6),
      stack_peak(map, 8),
      stack_0_peak(map),
      stack_1_peak(map),
      {{3, 0}, Map.get(map, {3, 0})},
      {{5, 0}, Map.get(map, {5, 0})},
      {{7, 0}, Map.get(map, {7, 0})}
    ]
    |> Enum.reject(&Kernel.is_nil/1)
    |> Enum.reject(fn {_, v} -> v == nil end)
    |> Enum.sort_by(fn {_, v} -> v end)
  end

  def display(map) do
    display(map, "")
  end

  def display(map, cost) do
    max_y = Map.keys(map) |> Enum.map(&elem(&1, 1)) |> Enum.max
    for y <- 0..max_y do
      for x <- 0..10, into: "" do
        if Map.has_key?(map, {x, y}) do
          Map.get(map, {x, y}, ".") || "."
        else
          " "
        end
      end
      |> IO.puts
    end
    IO.puts(cost)
    map
  end

  def first(_) do
    data()
    |> parse_map
    |> eliminate_correct_pieces
    |> find_solutions(0)
  end

  def second(_) do
    data2()
    |> parse_map
    |> eliminate_correct_pieces
    |> find_solutions(0)
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


# Day23.split_cubes([[10..12, 10..12, 10..12], [11..13, 11..13, 11..13]])
# |> IO.inspect
# Day23.split_cubes([[11..13, 11..13, 11..13], [10..12, 10..12, 10..12]])
# |> IO.inspect
# Day23.split_cubes([[9..13, 9..13, 9..13], [10..12, 10..12, 10..12]])
# |> IO.inspect
# Day23.split_cubes([[10..12, 10..12, 10..12], [9..13, 9..13, 9..13]])
# |> IO.inspect
:timer.tc(Day23, :run, [])
|> elem(0)
|> div(1000)
|> then(&IO.puts("Runtime: #{&1}ms"))
