import DiscordBM

enum BirdBotCommand: String, CaseIterable, Sendable {
  case ping

  var registration: Payloads.ApplicationCommandCreate {
    switch self {
    case .ping:
      Payloads.ApplicationCommandCreate(
        name: self.rawValue,
        description: "Check whether BirdBot is responding",
        dm_permission: false,
        type: .chatInput,
        contexts: [.guild]
      )
    }
  }

  var response: String {
    switch self {
    case .ping:
      "BirdBot is awake and connected."
    }
  }
}
