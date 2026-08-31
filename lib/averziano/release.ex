defmodule Averziano.Release do
  @moduledoc """
  Tasks that need to run from a built release, where Mix is unavailable.

      bin/averziano eval "Averziano.Release.migrate()"
  """

  alias Ecto.Migrator

  @app :averziano

  @doc """
  Runs every pending migration for all configured repos.
  """
  @spec migrate() :: :ok
  def migrate do
    :ok = load_app()

    Enum.each(repos(), fn repo ->
      {:ok, _result, _apps} =
        Migrator.with_repo(repo, &Migrator.run(&1, :up, all: true))
    end)
  end

  @doc """
  Rolls `repo` back down to `version`.
  """
  @spec rollback(module(), integer()) :: :ok
  def rollback(repo, version) do
    :ok = load_app()

    {:ok, _result, _apps} =
      Migrator.with_repo(repo, &Migrator.run(&1, :down, to: version))

    :ok
  end

  @spec repos() :: [module()]
  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  @spec load_app() :: :ok
  defp load_app do
    _ = Application.load(@app)
    :ok
  end
end
