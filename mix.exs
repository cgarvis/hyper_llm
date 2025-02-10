defmodule HyperLLM.MixProject do
  use Mix.Project

  @source_url "https://github.com/cgarvis/hyper_llm"
  @version "0.4.0"

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
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:git_ops, "~> 2.6.1", only: [:dev, :test]},
      {:req, "~> 0.5"}
    ]
  end

  defp package do
    [
      description: "Call all LLM APIs using the OpenAI format.",
      licenses: ["MIT"],
      links: %{
        "Changelog" => "#{@source_url}/blob/master/CHANGELOG.md",
        "GitHub" => @source_url
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      extras: ["README.md"],
      groups_for_modules: [
        Providers: [
          HyperLLM.Provider,
          ~r/HyperLLM\.Provider\..*/
        ]
      ]
    ]
  end
end
