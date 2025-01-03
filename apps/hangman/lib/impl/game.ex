defmodule Hangman.Impl.Game do
  alias Hangman.Type

  @type t :: %Hangman.Impl.Game{
          turns_left: integer,
          game_state: Type.state(),
          letters: list(String.t()),
          used: MapSet.t(String.t())
        }

  defstruct(
    turns_left: 7,
    game_state: :init,
    letters: [],
    used: MapSet.new()
  )

  @spec new_game() :: t
  def new_game do
    new_game(Dictionary.random_word())
  end

  @spec new_game(String.t()) :: t
  def new_game(word) do
    %__MODULE__{
      letters: word |> String.codepoints()
    }
  end

  @spec guess(t, String.t()) :: {t, Type.tally()}
  def guess(game = %{game_state: state}, _guess) when state in [:won, :lost] do
    game
    |> return_with_tally()
  end

  @spec guess(t, String.t()) :: {t, Type.tally()}
  def guess(game, guess) do
    accept_guess(game, guess, MapSet.member?(game.used, guess))
    |> return_with_tally()
  end

  defp accept_guess(game, _guess, _already_used = true) do
    %{game | game_state: :already_used}
  end

  defp accept_guess(game, guess, _unused) do
    %{game | used: MapSet.put(game.used, guess)}
    |> score_guess(Enum.member?(game.letters, guess))
  end

  defp score_guess(game, _good_guess = true) do
    news_state = has_won(MapSet.subset?(MapSet.new(game.letters), game.used))
    %{game | game_state: news_state}
  end

  defp score_guess(game = %{turns_left: 1}, _bad_guess) do
    %{game | game_state: :lost, turns_left: 0}
  end

  defp score_guess(game, _bad_guess) do
    %{game | game_state: :bad_guess, turns_left: game.turns_left - 1}
  end

  def tally(game) do
    %{
      turns_left: game.turns_left,
      game_state: game.game_state,
      letters: reveal_letters(game),
      used: game.used |> MapSet.to_list() |> Enum.sort()
    }
  end

  defp return_with_tally(game) do
    {game, tally(game)}
  end

  defp reveal_letters(game = %{game_state: :lost}) do
    game.letters
  end

  defp reveal_letters(game) do
    game.letters
    |> Enum.map(fn letter -> MapSet.member?(game.used, letter) |> reveal_check(letter) end)
  end

  defp reveal_check(true, letter), do: letter
  defp reveal_check(_, _letter), do: "_"

  defp has_won(true), do: :won
  defp has_won(_), do: :good_guess
end
