import DiscordBM

enum IBotCommand: String, CaseIterable, Sendable {
  case ping

  var registration: Payloads.ApplicationCommandCreate {
    switch self {
    case .ping:
      Payloads.ApplicationCommandCreate(
        name: self.rawValue,
        description: "Check whether iBot is responding",
        dm_permission: false,
        type: .chatInput,
        contexts: [.guild]
      )
    }
  }

  var response: String {
    switch self {
    case .ping:
      "iBot is awake and connected."
    }
  }
}
