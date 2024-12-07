defmodule HangmanImpGameTest do
  use ExUnit.Case
  alias Hangman.Impl.Game

  test "new game returns structure" do
    game = Game.new_game()

    assert game.turns_left == 7
    assert game.game_state == :init
    assert length(game.letters) > 0
  end

  test "new game returns list" do
    game = Game.new_game("wombat")
    assert game.letters == ["w", "o", "m", "b", "a", "t"]
  end

  test "state doesnt change when won or lost" do
    for state <- [:won, :lost] do
      game = Game.new_game("wombat")
      game = Map.put(game, :game_state, state)
      {new_game, _tally} = Game.guess(game, "x")
      assert new_game == game
    end
  end

  test "a duplicate guess" do
    game = Game.new_game()
    {game, _tally} = Game.guess(game, "x")
    assert game.game_state != :already_used
    {game, _tally} = Game.guess(game, "y")
    assert game.game_state != :already_used
    {game, _tally} = Game.guess(game, "x")
    assert game.game_state == :already_used
  end

  test "remember guess" do
    game = Game.new_game()
    {game, _tally} = Game.guess(game, "x")
    {game, _tally} = Game.guess(game, "y")

    assert MapSet.equal?(game.used, MapSet.new(["x", "y"]))
  end

  test "we record a letter in word" do
    game = Game.new_game("wombat")
    {game, _tally} = Game.guess(game, "w")
    {_game, tally} = Game.guess(game, "o")
    assert tally.game_state == :good_guess
  end

  test "we record a letter not word" do
    game = Game.new_game("car")
    {_game, tally} = Game.guess(game, "w")
    assert tally.game_state == :bad_guess
    assert tally.turns_left == 6
  end

  test "game sequence" do
    [
      # guess, state, turns_left, letters, used
      ["a", :bad_guess, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["a", :already_used, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["e", :good_guess, 6, ["_", "e", "_", "_", "_"], ["a", "e"]],
      ["x", :bad_guess, 5, ["_", "e", "_", "_", "_"], ["a", "e", "x"]]
    ]
    |> test_sequence("hello")
  end

  test "game sequence win" do
    [
      # guess, state, turns_left, letters, used
      ["x", :bad_guess, 6, ["_", "_", "_"], ["x"]],
      ["a", :good_guess, 6, ["a", "_", "_"], ["a", "x"]],
      ["p", :good_guess, 6, ["a", "p", "_"], ["a", "p", "x"]],
      ["e", :won, 6, ["a", "p", "e"], ["a", "e", "p", "x"]]
    ]
    |> test_sequence("ape")
  end

  test "game sequence loose" do
    [
      # guess, state, turns_left, letters, used
      ["x", :bad_guess, 6, ["_", "_", "_"], ["x"]],
      ["z", :bad_guess, 5, ["_", "_", "_"], ["x", "z"]],
      ["y", :bad_guess, 4, ["_", "_", "_"], ["x", "y", "z"]],
      ["b", :bad_guess, 3, ["_", "_", "_"], ["b", "x", "y", "z"]],
      ["c", :bad_guess, 2, ["_", "_", "_"], ["b", "c", "x", "y", "z"]],
      ["d", :bad_guess, 1, ["_", "_", "_"], ["b", "c", "d", "x", "y", "z"]],
      ["f", :lost, 0, ["_", "_", "_"], ["b", "c", "d", "f", "x", "y", "z"]]
    ]
    |> test_sequence("ape")
  end

  def test_sequence(sequences, word) do
    game = Game.new_game(word)
    Enum.reduce(sequences, game, &check_one_move/2)
  end

  defp check_one_move([guess, state, turns_left, letters, used], game) do
    {updated_game, tally} = Game.guess(game, guess)
    assert tally.game_state == state
    assert tally.turns_left == turns_left
    assert tally.letters == letters
    assert tally.used == used
    updated_game
  end
end
