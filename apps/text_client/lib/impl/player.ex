defmodule TextClient.Impl.Player do
  @typep game :: Hangman.game()
  @typep tally :: Hangman.Type.tally()
  @typep state :: {game, tally}

  @spec start(game) :: :ok
  def start(game) do
    tally = Hangman.tally(game)

    interact({game, tally})
  end

  def interact({_game, _tally = %{game_state: :won}}) do
    IO.puts("You won!")
  end

  def interact({_game, tally = %{game_state: :lost}}) do
    IO.puts("You lost..! the word was #{tally.letters |> Enum.join()}")
  end

  @spec interact(state) :: :ok
  def interact({game, tally}) do
    IO.puts(feedback_for(tally))
    IO.puts(current_word(tally))

    tally = Hangman.guess(game, get_guess())
    interact({game, tally})
  end

  ####################
  defp feedback_for(tally = %{game_state: :init}) do
    IO.puts("Welcome to Hangman! I am thinking of a #{length(tally.letters)} letter word")
  end

  defp feedback_for(_tally = %{game_state: :good_guess}) do
    IO.puts("Nice")
  end

  defp feedback_for(_tally = %{game_state: :bad_guess}) do
    IO.puts("Not in word")
  end

  defp feedback_for(_tally = %{game_state: :already_used}) do
    IO.puts("You already used that")
  end

  ####################
  def current_word(tally) do
    [
      "Words so far: ",
      tally.letters |> Enum.join(" "),
      "turns left: ",
      tally.turns_left |> to_string(),
      "letters used: ",
      tally.used |> Enum.join(",")
    ]
  end

  ####################
  def get_guess do
    IO.gets("Next letter: ")
    |> String.trim()
    |> String.downcase()
  end
end
