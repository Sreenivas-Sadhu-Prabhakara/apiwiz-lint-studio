# Downloading & installing the CLI

How anyone gets `apiwiz-lint` — with your org's custom rules already inside. Rules apply
automatically; no `--ruleset` needed.

## Option A — npm (recommended)

Build a tarball (UI **Download CLI → Build**, or `npm run pack:cli`). It lands in `dist/` as
`apiwiz-lint-<version>.tgz`. Share it, then:

```bash
npm install -g ./apiwiz-lint-1.0.1.tgz
```

Use it:

```bash
apiwiz-lint openapi.yaml                      # lint a single YAML/JSON file
apiwiz-lint manifests/*.yaml --format json   # multiple files, JSON output
apiwiz-lint api.yaml --format pretty         # human-friendly output
apiwiz-lint --list                           # list bundled rules
apiwiz-lint api.yaml --no-bundled-rules      # ignore bundled rules for one run
```

`apiwiz-lint` wraps the Spectral CLI, which is installed as a dependency — so all Spectral output
formats (`json`, `stylish`, `pretty`, `junit`, `html`, `sarif`, `github-actions`, …) and flags work.

### Private registry

Set a scoped name (e.g. `@your-org/apiwiz-lint`) in `cli/package.json`, then from `cli/`:

```bash
npm publish --registry https://your-registry
```

## Option B — Docker

```bash
docker build -t apiwiz-lint .                              # from the repo root
docker run --rm -v "$PWD:/work" apiwiz-lint /work/openapi.yaml --format stylish
docker run --rm apiwiz-lint --list
```

### In CI

```yaml
- name: Lint API specs
  run: |
    docker run --rm -v "$PWD:/work" \
      ghcr.io/your-org/apiwiz-lint:latest \
      /work/manifests --format json
```

## Exit codes

`0` = clean; `1` = findings at or above the fail severity. Use `--fail-severity warn` (a Spectral
flag, passed through) to gate CI on warnings too.

## Verify the rules are bundled

```bash
apiwiz-lint --list
# apiwiz-lint — N bundled rule(s):
#   path-kebab-case  [error]  ...
```
