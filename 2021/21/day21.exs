defmodule Day21 do
  def real_input do
    """
    Player 1 starting position: 10
    Player 2 starting position: 4
    """
  end

  def test do
    """
    Player 1 starting position: 4
    Player 2 starting position: 8
    """
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, ": "))
    |> Enum.map(&List.last/1)
    |> Enum.map(&String.to_integer/1)
  end

  def move({{pos, score}, name}, new_dice) do
    new_pos = Integer.mod(pos + new_dice.value - 1, 10) + 1
    {{{new_pos, score + new_pos}, name}, new_dice}
  end

  def play({{player_x, player_y}, dice}) do
    new_dice = roll(dice)
    {new_x, new_dice} = move(player_x, new_dice)
    { {player_y, new_x}, new_dice }
  end

  def roll(%{value: value, rolls: rolls}), do: %{value: value + 9, rolls: rolls + 3}
  def roll({:quantum_dice, r}), do: r

  def quantum_step({%{games: games} = state, dice}) do
    {
      %{ state | games: games
      |> Enum.reduce(%{}, fn {{player_x, player_y}, count}, acc ->
        Enum.reduce(roll(dice), acc, fn rolled, acc2 ->
          { new_x, _ } = move(player_x, rolled)
          Map.update(acc2, {player_y, new_x}, (count * rolled.count),
            fn x -> x + (count * rolled.count) end)
        end)
      end)
      },
      dice
    }
  end

  def update_games_won({%{games: games, games_won: games_won}, dice}) do
    { live_games, completed_games } =
      games
      |> Enum.split_with(&continue_game?(&1, 21))

    new_won = Enum.reduce(completed_games, games_won, fn {game, count}, acc ->
      Map.update(acc, winner(game), count, fn x -> count + x end)
    end)

    new_state = %{games: live_games, games_won: new_won }
    { new_state, dice }
  end

  def play_quantum_game(world) do
    world
    |> quantum_step
    |> update_games_won
  end

  def deterministic_dice do
    %{ value: -3, rolls: 0 }
  end

  def quantum_dice do
    rolls = for x <- 1..3, y <- 1..3, z <- 1..3, into: [] do
      x + y + z
    end
    |> Enum.frequencies
    |> Enum.map(fn {value, count} -> %{value: value, count: count} end)
    {:quantum_dice, rolls}
  end

  def continue_game?({{{{_, score_x}, _}, {{_, score_y}, _}}, _}, score) do
    score_x < score && score_y < score
  end

  def setup_game([pos1, pos2]) do
    { {{pos1, 0}, :player1}, {{pos2, 0}, :player2} }
  end

  def setup_quantum_game(x) do
    %{
      games: %{setup_game(x) => 1},
      games_won: %{player1: 0, player2: 0}
    }
  end

  def winner({{{_, x}, name_x}, {{_, y}, name_y}}) do
    if x > y, do: name_x, else: name_y
  end

  def loser_score({{_, x}, _}, {{_, y}, _}) when x < y, do: x
  def loser_score(_, {{_, y}, _}), do: y

  def result([{{x, y}, dice}]) do
    loser_score(x, y) * dice.rolls
  end

  def quantum_result([{%{games_won: games_won}, _}]) do
    games_won
    |> Map.values
    |> Enum.max
  end

  def live_games?({%{games: []}, _}), do: false
  def live_games?(_), do: true

  def input do
    real_input()
    # test()
    |> parse
  end

  def first(input) do
    game = input |> setup_game
    { game, deterministic_dice() }
    |> Stream.iterate(&play/1)
    |> Stream.drop_while(&continue_game?(&1, 1000))
    |> Enum.take(1)
    |> result
  end

  def second(input) do
    quantum_game = input |> setup_quantum_game
    { quantum_game, quantum_dice() }
    |> Stream.iterate(&play_quantum_game/1)
    |> Stream.drop_while(&live_games?/1)
    |> Enum.take(1)
    |> quantum_result
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

:timer.tc(Day21, :run, [])
|> elem(0)
|> div(1000)
|> then(&IO.puts("Runtime: #{&1}ms"))
