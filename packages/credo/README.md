# jlg_credo

The canonical [Credo](https://hexdocs.pm/credo) settings for `jlg`—maximalist opt-out

## Usage

```elixir
# mix.exs, in deps
{:jlg_credo, github: "jgeschwendt/elixir", sparse: "packages/credo", only: [:dev, :test], runtime: false}
```

```elixir
# .credo.exs
%{configs: [%{name: "default", plugins: [{Jlg.Credo, []}]}]}
```

`mix credo` then runs every check strict: `strict: true` rides in the base.

The base is [`credo.exs`](credo.exs), compiled into the plugin and registered through `Credo.Plugin.register_default_config/2`: it merges after Credo's defaults and before every `.credo.exs`, so yours win. In `checks:`, `disabled: [{check, []}]` turns a check off and `extra: [{check, params}]` turns one on or retunes it; `enabled:` replaces the whole list—never write it.

Every check Credo ships is on with its own param defaults—not the tuned ones in Credo's generated `.credo.exs`—including the ones Credo ships disabled. `ForbiddenModule` and `UnusedOperation` report nothing until a project gives them `modules:`.

`disabled`, in `credo.exs`, holds each check the base turns off, with the fact that turns it off:

| check                         | reason                                                                                                                     |
| ----------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| `Readability.PreferUnquotedAtoms` | runs only on Elixir < 1.8; Credo skips it under the 1.20 pin and prints a notice every run                              |
| `Refactor.CondInsteadOfIfElse` | mutually exclusive with `CondStatements` (Credo's own note); the four live apps write if/else 398 times, a two-clause cond 0 |
| `Refactor.MapInto`            | runs only on Elixir < 1.8 (as `PreferUnquotedAtoms`)                                                                      |
| `Warning.LazyLogging`         | runs only on Elixir < 1.8 (as `PreferUnquotedAtoms`)                                                                      |

Credo is pinned `== 1.7.19` (112 checks); a bump that ships a check `credo.exs` does not name fails the inventory test.
