defmodule JLG.Credo.MixProject do
  use Mix.Project

  def project do
    [
      app: :jlg_credo,
      # pinned exact: the inventory test fails when a Credo release ships a check
      # credo.exs does not name
      deps: [{:credo, "== 1.7.19"}],
      elixir: "~> 1.18",
      test_coverage: [summary: [threshold: 100]],
      version: "0.1.0"
    ]
  end
end
