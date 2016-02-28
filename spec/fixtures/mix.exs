defmodule Mixup.Mixfile do
  use Mix.Project

  def project do
    [app: :mixup,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps,
     default_task: "server"]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :cowboy, :plug]]
  end

  # defp escript_config do
  #   [main_module: Servelet]
  # end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [{:poison, "~> 1.3.1"},
      {:plug, "~> 0.11.0"},
      {:cowboy, "~> 1.0.0"}]
  end
end
