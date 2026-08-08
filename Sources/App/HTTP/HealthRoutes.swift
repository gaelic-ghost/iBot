import Hummingbird

struct ServiceStatusResponse: ResponseCodable, Equatable {
  let service: String
  let status: String
}

func registerHealthRoutes(
  on router: Router<AppRequestContext>,
  readiness: ServiceReadiness
) {
  router.get("/health") { _, _ in
    ServiceStatusResponse(service: "iBot", status: "healthy")
  }

  router.get("/ready") { _, _ in
    let state = await readiness.snapshot()
    return EditedResponse(
      status: state == .ready ? .ok : .serviceUnavailable,
      response: ServiceStatusResponse(service: "iBot", status: state.rawValue)
    )
  }
}
