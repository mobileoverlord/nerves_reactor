# Nerves.Reactor

Applications and utilities for hardware in the loop development using Nerves

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `nerves_reactor` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:nerves_reactor, "~> 0.1.0"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/nerves_reactor](https://hexdocs.pm/nerves_reactor).

## Usage

*Work In Progress*

Start by creating a new Nerves based project.
Create initial firmware and burn an SD Card.

Configure the reactor settings
```elixir
config :nerves, :reactor,
  host: "192.168.1.2"

```

Start the Reactor
`mix nerves.reactor`
