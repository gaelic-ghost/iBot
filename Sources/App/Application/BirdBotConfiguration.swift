import Configuration
import DiscordBM
import Foundation

struct BirdBotConfiguration: Sendable {
  let discord: DiscordConfiguration

  init(reader: ConfigReader) throws {
    self.discord = try DiscordConfiguration(reader: reader.scoped(to: "discord"))
  }
}

struct DiscordConfiguration: Sendable {
  let applicationID: ApplicationSnowflake
  let botToken: String
  let guildIDs: [GuildSnowflake]
  let messageContentIntentEnabled: Bool

  init(reader: ConfigReader) throws {
    guard let applicationID = reader.string(forKey: "applicationId") else {
      throw ConfigurationError.missingDiscordApplicationID
    }
    guard UInt64(applicationID) != nil else {
      throw ConfigurationError.invalidDiscordApplicationID(applicationID)
    }

    guard let botToken = reader.string(forKey: "botToken", isSecret: true) else {
      throw ConfigurationError.missingDiscordBotToken
    }
    guard !botToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      throw ConfigurationError.emptyDiscordBotToken
    }

    guard let guildIDList = reader.string(forKey: "guildIds") else {
      throw ConfigurationError.missingDiscordGuildIDs
    }
    let guildIDs =
      guildIDList
      .split(separator: ",")
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    guard !guildIDs.isEmpty else {
      throw ConfigurationError.missingDiscordGuildIDs
    }
    guard guildIDs.allSatisfy({ UInt64($0) != nil }) else {
      throw ConfigurationError.invalidDiscordGuildIDs(guildIDs)
    }

    self.applicationID = ApplicationSnowflake(applicationID)
    self.botToken = botToken
    self.guildIDs = guildIDs.map(GuildSnowflake.init)
    self.messageContentIntentEnabled = reader.bool(
      forKey: "messageContentIntentEnabled",
      default: false
    )
  }
}

enum ConfigurationError: Error, Equatable, LocalizedError {
  case emptyDiscordBotToken
  case invalidDiscordApplicationID(String)
  case invalidDiscordGuildIDs([String])
  case missingDiscordApplicationID
  case missingDiscordBotToken
  case missingDiscordGuildIDs

  var errorDescription: String? {
    switch self {
    case .emptyDiscordBotToken:
      "DISCORD_BOT_TOKEN is empty. Provide the bot token through the process environment or an ignored local .env file."
    case .invalidDiscordApplicationID(let value):
      "DISCORD_APPLICATION_ID must be a numeric Discord snowflake, but received '\(value)'. Copy the application ID from the Discord Developer Portal."
    case .invalidDiscordGuildIDs(let values):
      "DISCORD_GUILD_IDS contains a non-numeric Discord snowflake in '\(values.joined(separator: ","))'. Provide a comma-separated list of server IDs."
    case .missingDiscordApplicationID:
      "DISCORD_APPLICATION_ID is missing. Copy the application ID from the Discord Developer Portal into the process environment or an ignored local .env file."
    case .missingDiscordBotToken:
      "DISCORD_BOT_TOKEN is missing. Provide the bot token through the process environment or an ignored local .env file; never commit it to the repository."
    case .missingDiscordGuildIDs:
      "DISCORD_GUILD_IDS is empty. Provide a comma-separated list containing at least one approved Discord server ID."
    }
  }
}
