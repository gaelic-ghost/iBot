import Configuration
import Foundation
import Hummingbird
import HummingbirdTesting
import Logging
import Testing

@testable import BirdBot

private let reader = ConfigReader(providers: [
  InMemoryProvider(values: [
    "http.host": "127.0.0.1",
    "http.port": "0",
    "log.level": "trace",
  ])
])

@Suite
struct AppTests {
  @Test
  func healthReportsHealthyProcess() async throws {
    let app = try await buildApplication(reader: reader, readiness: ServiceReadiness())
    try await app.test(.router) { client in
      try await client.execute(uri: "/health", method: .get) { response in
        #expect(response.status == .ok)
        let status = try JSONDecoder().decode(
          ServiceStatusResponse.self,
          from: Data(response.body.readableBytesView)
        )
        #expect(status == ServiceStatusResponse(service: "BirdBot", status: "healthy"))
      }
    }
  }

  @Test
  func readinessTracksDiscordConnection() async throws {
    let readiness = ServiceReadiness()
    let app = try await buildApplication(reader: reader, readiness: readiness)

    try await app.test(.router) { client in
      try await client.execute(uri: "/ready", method: .get) { response in
        #expect(response.status == .serviceUnavailable)
        let status = try JSONDecoder().decode(
          ServiceStatusResponse.self,
          from: Data(response.body.readableBytesView)
        )
        #expect(status == ServiceStatusResponse(service: "BirdBot", status: "starting"))
      }

      await readiness.markReady()

      try await client.execute(uri: "/ready", method: .get) { response in
        #expect(response.status == .ok)
        let status = try JSONDecoder().decode(
          ServiceStatusResponse.self,
          from: Data(response.body.readableBytesView)
        )
        #expect(status == ServiceStatusResponse(service: "BirdBot", status: "ready"))
      }
    }
  }

  @Test
  func pingCommandIsGuildOnlyAndHarmless() {
    let command = BirdBotCommand.ping

    #expect(command.registration.name == "ping")
    #expect(command.registration.dm_permission == false)
    #expect(command.registration.contexts == [.guild])
    #expect(command.response == "BirdBot is awake and connected.")
  }
}

@Suite
struct ConfigurationTests {
  @Test
  func loadsApprovedGuildConfiguration() throws {
    let reader = ConfigReader(providers: [
      InMemoryProvider(values: [
        "discord.applicationId": "111111111111111111",
        "discord.botToken": "test-token",
        "discord.guildIds": "222222222222222222, 333333333333333333",
        "discord.messageContentIntentEnabled": true,
      ])
    ])

    let configuration = try BirdBotConfiguration(reader: reader)

    #expect(configuration.discord.applicationID.rawValue == "111111111111111111")
    #expect(
      configuration.discord.guildIDs.map(\.rawValue) == [
        "222222222222222222",
        "333333333333333333",
      ])
    #expect(configuration.discord.messageContentIntentEnabled)
  }

  @Test
  func mapsDocumentedEnvironmentVariableNames() throws {
    let reader = ConfigReader(providers: [
      EnvironmentVariablesProvider(environmentVariables: [
        "DISCORD_APPLICATION_ID": "111111111111111111",
        "DISCORD_BOT_TOKEN": "test-token",
        "DISCORD_GUILD_IDS": "222222222222222222,333333333333333333",
        "DISCORD_MESSAGE_CONTENT_INTENT_ENABLED": "true",
      ])
    ])

    let configuration = try BirdBotConfiguration(reader: reader)

    #expect(configuration.discord.applicationID.rawValue == "111111111111111111")
    #expect(configuration.discord.guildIDs.count == 2)
    #expect(configuration.discord.messageContentIntentEnabled)
  }

  @Test
  func missingTokenProducesActionableSecretSafeError() {
    let reader = ConfigReader(providers: [
      InMemoryProvider(values: [
        "discord.applicationId": "111111111111111111",
        "discord.guildIds": "222222222222222222",
      ])
    ])

    #expect(throws: ConfigurationError.missingDiscordBotToken) {
      try BirdBotConfiguration(reader: reader)
    }
    #expect(
      ConfigurationError.missingDiscordBotToken.errorDescription
        == "DISCORD_BOT_TOKEN is missing. Provide the bot token through the process environment or an ignored local .env file; never commit it to the repository."
    )
  }

  @Test
  func rejectsNonNumericGuildIDs() {
    let reader = ConfigReader(providers: [
      InMemoryProvider(values: [
        "discord.applicationId": "111111111111111111",
        "discord.botToken": "test-token",
        "discord.guildIds": "not-a-server-id",
      ])
    ])

    #expect(throws: ConfigurationError.invalidDiscordGuildIDs(["not-a-server-id"])) {
      try BirdBotConfiguration(reader: reader)
    }
  }
}
