defmodule TwoPhaseCommit.MixProject do
  use Mix.Project

  @github_url "https://github.com/qixxit/two_phase_commit"
  @example_github_url "https://github.com/qixxit/two_phase_commit_example"
  @description "A library to execute actions in a traceable manner."

  def project do
    [
      app: :two_phase_commit,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: @github_url,
      description: @description,
      name: "Two Phase Commit",
      package: package(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end

  defp package() do
    [
      licenses: ["BSD"],
      maintainers: ["Tobias Kräntzer", "Ed Ellson", "Dorian Iacobescu"],
      links: %{
        "GitHub" => @github_url,
        "Example" => @example_github_url
        # "Blog Post" => "https://medium.com/blog_post_url",
      },
      source_url: @github_url
    ]
  end

  defp docs() do
    [
      main: "readme",
      extras: ["README.md"]

      # logo: "maybe/a/logo.png",
    ]
  end
end
