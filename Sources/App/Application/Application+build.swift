import Configuration
import Hummingbird
import Logging

typealias AppRequestContext = BasicRequestContext

func makeLogger(reader: ConfigReader) -> Logger {
  var logger = Logger(label: "iBot")
  logger.logLevel = reader.string(forKey: "log.level", as: Logger.Level.self, default: .info)
  return logger
}

func buildApplication(
  reader: ConfigReader,
  readiness: ServiceReadiness,
  logger: Logger? = nil
) async throws -> some ApplicationProtocol {
  let router = buildRouter(readiness: readiness)
  return Application(
    router: router,
    configuration: ApplicationConfiguration(reader: reader.scoped(to: "http")),
    logger: logger ?? makeLogger(reader: reader)
  )
}

func buildRouter(readiness: ServiceReadiness) -> Router<AppRequestContext> {
  let router = Router(context: AppRequestContext.self)
  router.addMiddleware {
    LogRequestsMiddleware(.info)
  }
  registerHealthRoutes(on: router, readiness: readiness)
  return router
}
