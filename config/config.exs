import Config

config :git_ops,
  mix_project: HyperLLM.MixProject,
  changelog_file: "CHANGELOG.md",
  repository_url: "https://github.com/cgarvis/hyper_llm",
  manage_mix_version?: true,
  manage_readme_version?: true,
  version_tag_prefix: "v"
