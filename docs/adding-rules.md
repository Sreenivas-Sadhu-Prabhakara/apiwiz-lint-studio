# Adding linting rules (and getting them into the CLI)

Author a Spectral governance rule in the Studio and have it ship inside the downloadable CLI. No
separate ruleset for end users — the rule travels *inside* the CLI package, on top of the inherited
`spectral:oas` / `spectral:asyncapi` rulesets.

## The flow

```
  UI: New rule  ──▶  POST /api/rules  ──▶  validate against sample specs
                                          │  (real CLI / Spectral run, isolated)
                                          ▼
                              write cli/rules/custom/<name>.json
                                          │
  Download CLI: Build  ──▶  POST /api/cli/pack  ──▶  bump version + `npm pack`
                                          ▼
                              dist/apiwiz-lint-<version>.tgz
                                          │
                          anyone: npm i -g ./that.tgz  (rule is built in)
```

## 1. Open the Studio

```bash
npm start          # http://localhost:4800
```

Go to **+ New rule**.

## 2. Fill the rule

Every Spectral rule has four core pieces, plus a template that builds the `then` clause:

- **name** — kebab-case, unique (becomes the file name and the rule id).
- **description** — human-readable; also the default message.
- **given** — a **JSONPath** selecting what the rule applies to. Examples:
  - `$.info` — the info object
  - `$.info.contact` — the contact object
  - `$.paths[*]~` — each path *key* (the `~` selects the property name)
  - `$.paths[*][get,put,post,delete,patch]` — each operation
  - `$.components.schemas[*]` — each schema
- **severity** — `error`, `warn`, `info`, `hint`, or `off`.

## 3. Pick a template (the `then` clause)

| Template | Spectral function | Use it to… |
| -------- | ----------------- | ---------- |
| Field must be present & truthy | `truthy` | require a field exists and is non-empty (e.g. operation `summary`) |
| Field must be defined | `defined` | require a field exists (empty allowed) |
| Field must be absent / falsy | `falsy` | forbid a field |
| Value must match / not match a regex | `pattern` | enforce a path/version shape |
| Value must follow a casing style | `casing` | camelCase property names, etc. |
| Value must be one of a set | `enumeration` | restrict to allowed values |
| Length within bounds | `length` | min/max summary length, etc. |
| **Advanced** | any | write the `then` JSON yourself |

The optional **Field** narrows the check to a sub-property of the `given` match (e.g. `given:
$.info.contact`, field `email`). Leave it blank to apply the function to the matched value itself.

## 4. Validate

**Validate** runs the rule through the **real CLI/Spectral** against the sample fixtures
(`server/fixtures/`): an OpenAPI spec and an AsyncAPI doc. You get back whether it loaded cleanly,
how many findings it produced, the findings, and the generated Spectral YAML.

## 5. Create

**Create rule** re-validates and writes `cli/rules/custom/<name>.json`. A rule that fails to load is
never saved. It's immediately active for the local CLI:

```bash
node cli/bin.js server/fixtures/sample-openapi.yaml --format stylish
node cli/bin.js --list
```

## 6. Bundle it into a download

**Download CLI → Build new download** (or `npm run pack:cli`) bumps the version and runs `npm pack`,
producing `dist/apiwiz-lint-<version>.tgz` with your rule inside. See
[downloading-the-cli.md](downloading-the-cli.md).

## Inherited rules

The bundled ruleset `extends` `spectral:oas` and `spectral:asyncapi` (recommended), so your CLI
already enforces the standard OpenAPI/AsyncAPI checks. Your custom rules layer org-specific governance
on top. To turn an inherited rule off, add it to `rules` in `cli/rules/base.json` set to `"off"`.

## Without the UI

Drop a JSON spec into `cli/rules/custom/`:

```json
{
  "name": "require-operation-tags",
  "given": "$.paths[*][get,put,post,delete,patch]",
  "severity": "warn",
  "then": { "field": "tags", "function": "truthy" },
  "description": "Every operation should be tagged."
}
```

The CLI compiles everything in that folder at runtime.
