# Contributing To BirdBot

BirdBot is being developed for two Apple-platform development communities. Product behavior—especially moderation, permissions, message retention, and third-party processing—must be agreed with the participating server administrators before implementation.

## Development

1. Install Swift 6.3 or newer and the Hummingbird `hb` CLI.
2. Copy `.env.example` to `.env` and provide credentials for a dedicated development bot. Never use or commit a production token.
3. Run `swift build` and `swift test`.
4. Run `swift format lint --recursive --strict Package.swift Sources Tests` before opening a pull request.

Keep command and moderation rules independent from Discord transport code so their behavior can be tested without a live Gateway connection. Request only the Discord Gateway intents required by implemented features.

## Pull Requests

Keep pull requests focused and describe the user-visible behavior, configuration changes, security or privacy effects, and verification performed. Do not include private server configuration, message content, tokens, local `.env` files, or machine-local dependency paths.
