import DiscordBM
import Logging

struct DiscordEventHandler: GatewayEventHandler {
  let event: Gateway.Event
  let client: any DiscordClient
  let guildIDs: Set<GuildSnowflake>
  let readiness: ServiceReadiness
  let logger: Logger

  func onReady(_: Gateway.Ready) async throws {
    try await CommandRegistrar(
      client: self.client,
      guildIDs: Array(self.guildIDs),
      logger: self.logger
    ).registerCommands()
    await self.readiness.markReady()
    self.logger.notice("BirdBot's Discord Gateway session is ready for approved guild traffic")
  }

  func onResumed() async {
    await self.readiness.markReady()
    self.logger.notice(
      "BirdBot resumed its Discord Gateway session after a connection interruption")
  }

  func onInvalidSession(canResume: Bool) async {
    await self.readiness.markConnecting()
    self.logger.warning(
      "Discord invalidated BirdBot's Gateway session; DiscordBM will reconnect using the supported session path",
      metadata: ["can-resume": .stringConvertible(canResume)]
    )
  }

  func onInteractionCreate(_ interaction: Interaction) async throws {
    guard
      interaction.type == .applicationCommand,
      let guildID = interaction.guild_id,
      self.guildIDs.contains(guildID),
      let data = interaction.data,
      let command = BirdBotCommand(rawValue: try data.requireApplicationCommand().name)
    else {
      return
    }

    let response = try await self.client.createInteractionResponse(
      id: interaction.id,
      token: interaction.token,
      payload: .channelMessageWithSource(.init(content: command.response))
    )
    try response.guardSuccess()
  }

  func onMessageCreate(_ message: Gateway.MessageCreate) async {
    guard let guildID = message.guild_id, self.guildIDs.contains(guildID) else {
      return
    }
    self.logger.trace(
      "Observed a message event in an approved guild; no moderation policy is configured, so BirdBot took no action",
      metadata: [
        "channel-id": .string(message.channel_id.rawValue),
        "guild-id": .string(guildID.rawValue),
        "message-id": .string(message.id.rawValue),
      ]
    )
  }
}
