# BirdBot Repository Guidance

Use this file for durable repo-local guidance before changing BirdBot.

## Service Shape

- BirdBot is a Hummingbird 2 server-side Swift service created with the official `hb` CLI as a long-running Server application.
- Keep Swift Package Manager as the source of truth for package structure, dependencies, builds, tests, and run commands.
- Preserve Hummingbird's generated `swift-configuration` provider model. Do not add a parallel settings loader.
- DiscordBM owns Discord Gateway and REST API behavior. Hummingbird owns the health and readiness HTTP surface.
- BirdBot v1 intentionally has no database. Do not add Fluent, PostgreSQL, SQLite, or another persistence system until product requirements identify state that must survive process restarts and Gale approves the new operational surface.
- Semantic similarity and model-backed moderation are deferred product and privacy decisions. Do not add model providers, embeddings, vector storage, or message-content transmission to third parties without Gale's explicit approval.

## Architecture

- Keep dependency injection unidirectional: process configuration creates runtime dependencies, transport adapters call feature logic, and feature logic returns explicit results.
- Keep deterministic moderation and command behavior separate from Discord event transport so it can be tested without a live bot token or Gateway connection.
- Keep Hummingbird route registration readable and delegate meaningful behavior out of route closures.
- Prefer small files and types with one main job. Put reusable support in explicit support surfaces rather than unrelated feature entry points.
- Do not add managers, repositories, coordinators, wrappers, or compatibility paths without a concrete current use case and Gale's approval when the change widens the architecture.

## Configuration And Secrets

- Runtime configuration flows through `swift-configuration` in this order: command-line arguments, environment variables, optional local `.env`, and safe in-memory defaults.
- The Discord bot token is required for the production bot process and must never be committed, printed, embedded in an image, or included in an error.
- Error and log messages must name the missing setting, where BirdBot expected it, and the likely fix without exposing secret values.
- Committed examples must contain placeholders only. Real deployment values belong in the deployment provider's secret store or an ignored local `.env` file.

## Discord Safety

- Request only the Gateway intents required by implemented features.
- Treat automatic moderation actions as product-policy changes. Do not add destructive moderation actions until their authorization, audit trail, false-positive behavior, and per-guild configuration are approved.
- Keep the initial interaction surface harmless and guild-scoped during development when practical.
- Respect Discord rate limits and use DiscordBM's typed API and retry behavior instead of constructing ad hoc Discord HTTP requests.

## Docker And Deployment

- Keep the `hb`-generated multi-stage Dockerfile as the image baseline.
- The production target is one dedicated 1 GB Linux VM. Build the release artifact or image in CI; do not compile Swift on the production VM.
- Keep application code provider-neutral. AWS Lightsail is the first intended host, not an application-layer dependency.
- Do not provision, resize, restart, or otherwise mutate billable cloud infrastructure without Gale's explicit approval for that operation.

## Validation

Run the narrowest relevant checks during implementation and the complete baseline before publishing a ready checkpoint:

```bash
swift build
swift test
docker build .
```

- Run SwiftPM and Docker build operations strictly one at a time.
- Runtime checks that connect to Discord require a separately supplied test bot token and explicit approval before using a real server.
- Health and readiness route behavior should be proven through Hummingbird's in-process testing support whenever possible.

## Git And Public Repository

- Work on feature branches unless Gale explicitly approves direct work on `main` for the task.
- Never commit tokens, `.env` files, private server configuration, machine-local paths, or private dependency URLs.
- Keep public documentation clear about which behavior exists now and which features remain planned.
