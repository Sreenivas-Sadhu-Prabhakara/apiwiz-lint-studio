# Self-contained image for apiwiz-lint (Spectral wrapper with bundled rules).
# Build context is the repo root; only the cli/ wrapper is copied in.
#
#   docker build -t apiwiz-lint .
#   docker run --rm -v "$PWD:/work" apiwiz-lint /work/config.yaml --format stylish
#
FROM node:20-bookworm-slim AS build
WORKDIR /opt/apiwiz-lint
COPY cli/package.json ./package.json
RUN npm install --omit=dev --no-audit --no-fund
COPY cli/ ./

FROM node:20-bookworm-slim
WORKDIR /work
ENV NODE_ENV=production
COPY --from=build /opt/apiwiz-lint /opt/apiwiz-lint
ENTRYPOINT ["node", "/opt/apiwiz-lint/bin.js"]
CMD ["--help"]
