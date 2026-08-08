actor ServiceReadiness {
  enum State: String, Codable, Equatable, Sendable {
    case starting
    case connecting
    case ready
    case stopped
  }

  private var state: State = .starting

  func snapshot() -> State {
    self.state
  }

  func markConnecting() {
    self.state = .connecting
  }

  func markReady() {
    self.state = .ready
  }

  func markStopped() {
    self.state = .stopped
  }
}
