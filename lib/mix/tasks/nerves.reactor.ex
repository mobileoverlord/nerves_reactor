# defmodule Mix.Tasks.Nerves.Reactor do
#   use Mix.Task
#
#   @switches [node: :string, target: :string]
#
#   @moduledoc """
#
#   Start a local reactor session.
#
#   """
#   def run([node | argv]) do
#     {opts, _, _} = OptionParser.parse(argv, switches: @switches)
#     app = Mix.Project.config[:app]
#     node = :"#{node}"
#
#
#     Application.ensure_all_started(:nerves_reactor)
#     Nerves.Reactor.Agent.start_link()
#     Nerves.Reactor.Agent.put(:target, opts[:target])
#     Nerves.Reactor.Agent.put(:node, opts[:node])
#     Nerves.Reactor.Agent.put(:host_node, opts[:node])
#     Nerves.Reactor.Agent.put(:cookie, opts[:cookie])
#     Mix.Task.run("run", ["--no-halt"])
#   end
# end

# mix nerves.reactor
defmodule Mix.Tasks.Nerves.Reactor do
  use Mix.Task

  @switches [target: :string]

  def run(argv) do
    {opts, _, _} = OptionParser.parse(argv, switches: @switches)

    case System.get_env("REACTOR_RUNNING") do
      nil ->
        IO.puts "Reactor is starting #{Mix.Project.config[:target]}"
        System.put_env("MIX_TARGET", opts[:target])
        System.put_env("REACTOR_RUNNING", "true")
        :init.restart
        :timer.sleep(:infinity)
      _ ->
        # do inter env work
        target = System.get_env("MIX_TARGET")
        IO.inspect target
        IO.puts "Reactor is running #{Mix.Project.config[:target]}"
    end
  end
end
