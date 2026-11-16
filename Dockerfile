# Built by .github/workflows/deploy.yml and pushed to Artifact Registry.
#
# This template has NO main package - it is a library plus its tests - so the
# fleet's go stack pack does not apply: its build stage would fail with "no Go
# files in ./cmd/app", and a distroless runtime has no toolchain to run tests
# with. This image is a TEST RUNNER: it keeps the Go toolchain and runs the
# suite as its entrypoint.
FROM golang:1.25-alpine AS build
# Never run as root: a numeric non-root user, with the Go caches somewhere it can write.
RUN adduser -D -u 10001 app && mkdir -p /src /go-cache && chown -R 10001:10001 /src /go-cache
ENV GOCACHE=/go-cache/build GOMODCACHE=/go-cache/mod
USER 10001:10001
WORKDIR /src
ARG BUILD_ID=""
ENV BUILD_ID=$BUILD_ID CGO_ENABLED=0
COPY --chown=10001:10001 go.mod go.sum* ./
RUN go mod download
COPY --chown=10001:10001 . .
RUN go vet ./... && go build ./...
ENTRYPOINT ["go", "test", "./...", "-v"]
