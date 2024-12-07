defmodule TextClient.Impl.Player do
  @typep game :: Hangman.game()
  @typep tally :: Hangman.Type.tally()
  @typep state :: {game, tally}

  @spec start() :: :ok
  def start() do
    game = Hangman.new_game()
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
  def interact(state) do
    IO.puts(feedback_for(state.tally))
  end

  @spec feedback_for(tally) :: :ok
  defp feedback_for(tally = %{game_state: :initializing}) do
    IO.puts("Welcome to Hangman! I am thinking of a #{tally.} letter word")
  end
  defp feedback_for(_tally = %{game_state: :initializing}) do
    IO.puts("Welcome to Hangman!")
  end
end
