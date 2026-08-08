import DiscordBM
import Logging

struct CommandRegistrar: Sendable {
  let client: any DiscordClient
  let guildIDs: [GuildSnowflake]
  let logger: Logger

  func registerCommands() async throws {
    let commands = BirdBotCommand.allCases.map(\.registration)
    for guildID in self.guildIDs {
      let response = try await self.client.bulkSetGuildApplicationCommands(
        guildId: guildID,
        payload: commands
      )
      try response.guardSuccess()
      self.logger.info(
        "Registered BirdBot's approved guild command set with Discord",
        metadata: ["guild-id": .string(guildID.rawValue)]
      )
    }
  }
}
