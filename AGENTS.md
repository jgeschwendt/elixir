# elixir

```stele
kind: system
purpose: Mix-package monorepo for jlg's Elixir configs — jlg_credo, the canonical Credo config as a Credo plugin, consumed as a sparse git dependency. The packages ARE the product.
commands:
  check: mise run check
  credo: mise x -C packages/credo -- mix credo --strict
  format-check: mise x -C packages/credo -- mix format --check-formatted
  test: mise x -C packages/credo -- mix test --cover
```

## Map

| node             | purpose                                                                                                                                                           |
| ---------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `packages/credo` | `credo.exs` is the canonical config (every check on, reasoned `disabled`); `lib/jlg/credo.ex` compiles it in and registers it; `test/` inventories and end-to-ends it |
