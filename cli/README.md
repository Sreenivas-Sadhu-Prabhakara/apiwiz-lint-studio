# apiwiz-lint

A Spectral-based linter for **OpenAPI & AsyncAPI** specs with your organization's governance rules
**bundled in**. Authored via
[Apiwiz Lint Studio](https://github.com/Sreenivas-Sadhu-Prabhakara/apiwiz-lint-studio); ship inside
this CLI.

## Install

```bash
npm install -g ./apiwiz-lint-<version>.tgz   # from a packed tarball
```

## Use

```bash
apiwiz-lint openapi.yaml                      # lint a spec (bundled rules apply automatically)
apiwiz-lint specs/*.yaml --format json        # multiple files, JSON output
apiwiz-lint --list                            # list the bundled rules
apiwiz-lint api.yaml --ruleset my.yaml        # use your own ruleset instead
apiwiz-lint api.yaml --no-bundled-rules       # skip the bundled rules for one run
```

Any flags other than the wrapper's own pass straight through to `spectral lint`.

## How it works

`apiwiz-lint` wraps [`@stoplight/spectral-cli`](https://github.com/stoplightio/spectral). At runtime
it compiles a ruleset from `rules/base.json` (which `extends` `spectral:oas` + `spectral:asyncapi`) +
every `rules/custom/*.json` (the studio-authored governance rules) and applies it by default — so a
downloaded CLI already carries the standard checks *and* your org's rules, no `--ruleset` needed.

Custom rules are plain Spectral rules: a `given` (JSONPath), a `then` (function + options) and a
`severity`. Add or edit them in Apiwiz Lint Studio, or drop a JSON spec into `rules/custom/`.
