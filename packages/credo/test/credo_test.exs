defmodule JLG.CredoTest do
  use ExUnit.Case, async: true

  alias Credo.Execution
  alias Credo.Execution.Task.InitializePlugins

  @moduletag timeout: :infinity
  @package Path.expand("..", __DIR__)
  @tmp Path.join(System.tmp_dir!(), "jlg_credo")

  test "credo.exs names every check the pinned Credo ships, alphabetically, and nothing else" do
    [{:plugin, JLG.Credo, config}] =
      %{Execution.build() | plugins: [{JLG.Credo, []}]}
      |> InitializePlugins.call([])
      |> Execution.get_config_files()

    {%{configs: [%{checks: %{disabled: disabled, enabled: enabled}}]}, _} =
      Code.eval_string(config)

    {:ok, modules} = :application.get_key(:credo, :modules)
    checks = for m <- modules, {:behaviour, [Credo.Check]} in m.module_info(:attributes), do: m
    names = Keyword.keys(enabled)
    all = Keyword.keys(enabled ++ disabled)
    assert names == Enum.sort(names)
    assert Enum.sort(all) == Enum.sort(checks)
  end

  test "the consumer lines, as a sparse git dependency, run every check strict" do
    {_, 0} =
      sh("""
      rm -rf #{@tmp}/src && mkdir -p #{@tmp}/src/packages/credo && cd #{@package}
      cp -R credo.exs lib mix.exs #{@tmp}/src/packages/credo && cd #{@tmp}/src
      git init -q && git add . && git -c user.email=t -c user.name=t commit -qm fixture
      """)

    assert credo("git", ~s(git: "file://#{@tmp}/src", sparse: "packages/credo"), "") ==
             [false, true, true]
  end

  test "a project's checks merge over the plugin's" do
    checks =
      "checks: %{disabled: [{Credo.Check.Readability.Specs, []}], extra: [{Credo.Check.Refactor.CondInsteadOfIfElse, []}]},"

    assert credo("path", ~s(path: "#{@package}"), checks) == [true, true, false]
  end

  # a Mix project whose one function trips CondInsteadOfIfElse (off in credo.exs),
  # ParenthesesOnZeroArityDefs (strict only) and Specs (off in Credo's defaults)
  defp credo(name, dep, checks) do
    {_, 0} =
      sh("""
      rm -rf #{@tmp}/#{name} && mkdir -p #{@tmp}/#{name}/lib && cd #{@tmp}/#{name}
      cat > mix.exs <<'EOF'
      defmodule Fixture.MixProject do
        use Mix.Project
        def project, do: [app: :fixture, deps: [{:jlg_credo, #{dep}, only: [:dev, :test], runtime: false}], version: "0.1.0"]
      end
      EOF
      echo '%{configs: [%{#{checks} name: "default", plugins: [{JLG.Credo, []}]}]}' > .credo.exs
      printf 'defmodule Fixture do\\n  @moduledoc false\\n  def zero(), do: if(true, do: 1, else: 2)\\nend\\n' > lib/fixture.ex
      mix do deps.get + deps.compile
      """)

    {json, _} = sh("cd #{@tmp}/#{name} && mix credo --format json 2>/dev/null")
    %{"issues" => issues} = JSON.decode!(json)
    found = for %{"check" => "Credo.Check." <> check} <- issues, do: check

    for check <-
          ~w(Refactor.CondInsteadOfIfElse Readability.ParenthesesOnZeroArityDefs Readability.Specs),
        do: check in found
  end

  # a hook's GIT_DIR or `mix test`'s MIX_ENV would steer the fixture's git and mix
  defp sh(script),
    do:
      System.cmd("sh", ["-ec", "exec 2>&1\n" <> script],
        env: [{"GIT_DIR", nil}, {"MIX_ENV", nil}]
      )
end
