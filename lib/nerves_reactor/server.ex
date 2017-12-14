defmodule Nerves.Reactor.Server do
  use GenServer
  alias Nerves.Reactor.Agent
  require Logger

  def start_link(opts \\ nil) do
    opts = opts || Agent.get()
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do


    target = opts[:target]
    target_node = opts[:node] |> String.to_atom
    change_target(target)
    app = Mix.Project.config[:app]
    host_node = opts[:host_node] || "#{app}_reactor@127.0.0.1"
    :net_kernel.start([:"#{host_node}"])
    if cookie = opts[:cookie] do
      Node.set_cookie(:"#{cookie}")
    end
    Application.ensure_started(:fs)
    IO.puts "Nerves Reactor Starting"
    paths = paths(Mix.Project.config)
    monitor_paths(paths)
    {:ok, %{
      paths: paths,
      target_node: target_node,
    }}
  end

  def handle_info({_pid, {:fs, :file_event}, {path, _event}}, s) do
    IO.puts "Path: #{inspect path}"
    path = to_string(path)
    if Enum.any?(s.paths, &String.starts_with?(path, &1)) do
      IO.inspect "Monitored File Changed"
      Mix.Project.build_structure
      Mix.Tasks.Compile.Elixir.run ["--silent"]
      Bootloader.ApplicationController.clear_cache
      source = Bootloader.ApplicationController.hash
      |> IO.inspect
      target = Bootloader.Utils.rpc(s.target_node, Bootloader.ApplicationController, :hash, [])
      |> IO.inspect
      if source != target do
        IO.puts "Calculating Overlay"
        sources = Bootloader.ApplicationController.applications
        targets = Bootloader.Utils.rpc(s.target_node, Bootloader.ApplicationController, :applications, [])
        overlay = Bootloader.Overlay.load(sources, targets)
        IO.puts "Applying Overlay"
        Bootloader.Utils.rpc(s.target_node, Bootloader.ApplicationController, :apply_overlay, [overlay])
        IO.puts "Done"
      end
    end
    {:noreply, s}
  end

  def paths(config) do
    elixirc_paths = Enum.map(config[:elixirc_paths], &Path.expand/1)
    deps_paths = deps_paths(config[:deps])
    paths = elixirc_paths ++ deps_paths
  end

  def monitor_paths(paths) do
    Enum.reduce(paths, 0, fn(path, acc) ->
      key = :"path#{acc}"
      :fs.start_link(key, Path.expand(path))
      :fs.subscribe(key)
      acc = acc + 1
    end)
  end

  def change_target(target) do
    target = "rpi3"
    project_config = Mix.Project.pop
    mix_file = project_config.file
    mod = project_config.name
    System.put_env("MIX_TARGET", target)
    Code.unload_files(Code.loaded_files)
    :code.purge mod
    :code.delete mod
    Mix.ProjectStack.clear_cache
    Code.load_file(mix_file)
    deps_paths = Mix.Project.deps_paths
  end

  # def in_target(project, target, fun) do
  #   change_target(project, target)
  #   #Mix.Project.in_project(project, File.cwd!, fun)
  # end
  #
  # def target_config(project, target) do
  #
  #   #in_target(project, target, fn(_module) ->
  #     Mix.Project.config
  #   #end)
  # end

  def deps_paths(deps) do
    deps =
      deps
      |> Enum.filter(fn
        {_, opts} when is_list(opts) ->
          Keyword.get(opts, :path) != nil or
          Keyword.get(opts, :in_umbrella) != nil
        _ -> false
      end)
      |> Enum.map(fn
        {app, _} -> app
        {app, _, _} -> app
      end)

    Mix.Project.deps_paths
    |> Enum.filter_map(fn({app, _path}) -> app in deps end, fn({_app, path}) -> path end)
  end
end
