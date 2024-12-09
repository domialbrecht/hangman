defmodule Hangman.Runtime.Server do
  @type t :: pid()
  alias Hangman.Impl.Game
  use GenServer

  ### server
  def init(_init_arg) do
    {:ok, Game.new_game()}
  end

  def handle_call({:make_move, guess}, _from, game) do
    {updated_game, tally} = Game.guess(game, guess)
    {:reply, tally, updated_game}
  end

  def handle_call({:tally}, _from, game) do
    {:reply, Game.tally(game), game}
  end

  ### client
  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end
end
