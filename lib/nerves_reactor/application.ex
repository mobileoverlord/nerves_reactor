defmodule Nerves.Reactor.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    IO.puts "HERE"
    # Define workers and child supervisors to be supervised
    children = [
      #worker(Nerves.Reactor.Server, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Nerves.Reactor.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
