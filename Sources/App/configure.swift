import FluentPostgreSQL
import Authentication
import SimpleFileLogger
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentPostgreSQLProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    // Register loggers
    let printLogger = PrintLogger()
    services.register(printLogger)
    
    let fileLogger = SimpleFileLogger()
    services.register(fileLogger)

    // Auth
    try services.register(AuthenticationProvider())
    
    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
    
    // Configure a PostgreeSql
    if let database = getDatabase() {
        var databases = DatabasesConfig()
        databases.add(database: database, as: .psql)
        services.register(databases)
    }
    
    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Todo.self, database: .psql)
    services.register(migrations)
}

private func getDatabase() -> PostgreSQLDatabase? {
    do {
        let postrgreSql = try PostgreSQLDatabase(fromConfig: "database_config.json") ?? PostgreSQLDatabase(config: .default())
        return postrgreSql
    } catch {
        PrintLogger().log(.error(error), file: #file, function: #function, line: #line, column: #column)
        return nil
    }
}
