import DiscordBM
import Logging
import ServiceLifecycle

struct DiscordGatewayService: Service {
  let configuration: DiscordConfiguration
  let readiness: ServiceReadiness
  let logger: Logger

  func run() async throws {
    var intents: [Gateway.Intent] = [.guilds, .guildMessages]
    if self.configuration.messageContentIntentEnabled {
      intents.append(.messageContent)
    }

    let gateway = await BotGatewayManager(
      token: self.configuration.botToken,
      appId: self.configuration.applicationID,
      intents: intents
    )
    await self.readiness.markConnecting()

    await cancelWhenGracefulShutdown {
      await withTaskCancellationHandler {
        await gateway.connect()
        for await event in await gateway.events {
          await DiscordEventHandler(
            event: event,
            client: gateway.client,
            guildIDs: Set(self.configuration.guildIDs),
            readiness: self.readiness,
            logger: self.logger
          ).handleAsync()
        }
      } onCancel: {
        Task {
          await gateway.disconnect()
          await self.readiness.markStopped()
        }
      }
    }
  }
}
