defmodule Hangman do
  alias Hangman.Runtime.Server
  alias Hangman.Type

  @opaque gamepid :: Server.t()

  @spec new_game() :: gamepid
  def new_game do
    {:ok, pid} = Hangman.Runtime.Application.start_game()
    pid
  end

  @spec guess(gamepid, String.t()) :: Type.tally()
  def guess(gamepid, guess) do
    GenServer.call(gamepid, {:make_move, guess})
  end

  @spec tally(gamepid) :: Type.tally()
  def tally(gamepid) do
    GenServer.call(gamepid, {:tally})
  end
end
