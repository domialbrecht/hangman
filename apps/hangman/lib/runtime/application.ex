defmodule Hangman.Runtime.Application do
  use Application

  @super_name GameStarter

  def start(_type, _args) do
    supervisor = [
      {DynamicSupervisor, strategy: :one_for_one, name: @super_name}
    ]

    Supervisor.start_link(supervisor, strategy: :one_for_one)
  end

  def start_game() do
    DynamicSupervisor.start_child(@super_name, {Hangman.Runtime.Server, nil})
  end
end
