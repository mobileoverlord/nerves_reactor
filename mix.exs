defmodule Nerves.Reactor.Mixfile do
  use Mix.Project

  def project do
    [app: :nerves_reactor,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger, :mix],
     mod: {Nerves.Reactor.Application, []}]
  end

  defp deps do
    [{:nerves, "~> 0.4.0", runtime: false},
     {:fs, "~> 2.12.0"}]
  end
end
