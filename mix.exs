defmodule HyperLlm.MixProject do
  use Mix.Project

  @version "0.0.1"
  @source_url "https://github.com/cgarvis/hyper-llm"

  def project do
    [
      app: :hyper_llm,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:req, "~> 0.5.8"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false}
    ]
  end

  defp package do
    [
      description: "A single interface for interacting with LLM providers.",
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      extras: ["README.md"]
    ]
  end
end
