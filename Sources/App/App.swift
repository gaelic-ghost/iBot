import Configuration
import Hummingbird
import Logging
import ServiceLifecycle

@main
struct App {
  static func main() async throws {
    // Application will read configuration from the following in the order listed
    // Command line, Environment variables, dotEnv file, defaults provided in memory
    let reader = try await ConfigReader(providers: [
      CommandLineArgumentsProvider(),
      EnvironmentVariablesProvider(),
      EnvironmentVariablesProvider(environmentFilePath: ".env", allowMissing: true),
      InMemoryProvider(values: [
        "discord.messageContentIntentEnabled": false,
        "http.serverName": "iBot",
      ]),
    ])
    let configuration = try IBotConfiguration(reader: reader)
    let readiness = ServiceReadiness()
    let logger = makeLogger(reader: reader)
    let application = try await buildApplication(
      reader: reader,
      readiness: readiness,
      logger: logger
    )
    let discord = DiscordGatewayService(
      configuration: configuration.discord,
      readiness: readiness,
      logger: logger
    )
    let services = ServiceGroup(
      services: [application, discord],
      gracefulShutdownSignals: [.sigterm, .sigint],
      logger: logger
    )
    try await services.run()
  }
}
