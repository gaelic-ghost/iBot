# BirdBot

BirdBot is a server-side Swift Discord bot being built for two Apple-platform development communities. The bootstrap establishes a safe, observable Gateway process while the participating server administrators define the full command and moderation requirements.

## Current Behavior

- Connects to Discord through a persistent, reconnecting Gateway session.
- Restricts command handling and message observation to explicitly configured guild IDs.
- Registers a harmless guild-only `/ping` command.
- Observes approved-guild message events without logging message content or applying moderation actions.
- Exposes `/health` for process liveness and `/ready` for Discord session readiness.
- Coordinates the HTTP server and Discord connection with graceful `SIGTERM` and `SIGINT` shutdown.

Semantic similarity, model-backed moderation, persistent moderation history, and destructive moderation actions are intentionally deferred until the server administrators approve their product, privacy, and operational requirements.

## Architecture

[Hummingbird](https://github.com/hummingbird-project/hummingbird) owns the HTTP health surface. [DiscordBM](https://github.com/DiscordBM/DiscordBM) owns typed Discord Gateway events, interactions, REST requests, reconnection behavior, and rate-limit handling. [Swift Service Lifecycle](https://github.com/swift-server/swift-service-lifecycle) starts and stops both services as one process. [Swift Configuration](https://github.com/apple/swift-configuration) supplies command-line, environment, optional `.env`, and safe default configuration.

BirdBot intentionally has no database in its initial shape. Deterministic command and moderation behavior belongs outside the Discord transport layer so it can be tested without a live bot token.

## Requirements

- Swift 6.3 or newer
- The Hummingbird [`hb` CLI](https://github.com/hummingbird-project/hb)
- A dedicated Discord application and development bot token
- Docker-compatible runtime for image validation or deployment

## Configuration

Copy `.env.example` to `.env` for local development:

```sh
cp .env.example .env
```

| Variable | Required | Meaning |
| --- | --- | --- |
| `DISCORD_APPLICATION_ID` | Yes | Numeric application ID from the Discord Developer Portal |
| `DISCORD_BOT_TOKEN` | Yes | Secret bot token; never commit or print it |
| `DISCORD_GUILD_IDS` | Yes | Comma-separated allowlist of Discord server IDs |
| `DISCORD_MESSAGE_CONTENT_INTENT_ENABLED` | No | Enables the privileged Message Content intent; defaults to `false` |
| `HTTP_HOST` | No | HTTP bind address; container default is `0.0.0.0` |
| `HTTP_PORT` | No | HTTP port; defaults to `8080` |
| `LOG_LEVEL` | No | Swift Log level; defaults to `info` |

Enable the privileged Message Content intent in both BirdBot configuration and the Discord Developer Portal only after a feature genuinely needs message text.

## Develop And Validate

```sh
swift build
swift test
swift format lint --recursive --strict Package.swift Sources Tests
```

Run the service only with a dedicated development bot and approved test guilds:

```sh
swift run BirdBot
```

The health responses are:

- `GET /health`: HTTP 200 while the process and Hummingbird router are functioning.
- `GET /ready`: HTTP 200 only after Discord connects and the approved guild command set is registered; otherwise HTTP 503.

## Container And VM Deployment

The generated multi-stage Dockerfile builds a release executable and runs it as a non-root user. Build it locally with:

```sh
docker build --tag birdbot:local .
```

`deploy/compose.yaml` is the production VM handoff. It expects a prebuilt immutable image in GitHub Container Registry and a host-managed `deploy/.env`; it does not compile Swift on the 1 GB VM. Image publishing and AWS Lightsail provisioning remain separate, approval-gated deployment work.

## Security

Tokens, private server configuration, and message content must never be committed. Report vulnerabilities privately through GitHub as described in the [security policy](.github/SECURITY.md).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). BirdBot does not have an open-source license yet; public visibility does not grant permission to redistribute or reuse the code until a license is selected.
