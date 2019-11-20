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
    services.register(AuthService.self)
    
    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
    
    // Configure a PostgreeSql
    if let database = getDatabase() {
        var databases = DatabasesConfig()
        databases.enableLogging(on: .psql)
        databases.add(database: database, as: .psql)
        services.register(databases)
    }
    
    // Configure migrations
    var migrationsConfig = MigrationConfig()
    addMigrations(to: &migrationsConfig)
    services.register(migrationsConfig)
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

private func addMigrations(to config: inout MigrationConfig) {
    config.add(model: Author.self, database: .psql)
    config.add(model: Book.self, database: .psql)
    config.add(model: BookAuthor.self, database: .psql)
    config.add(model: Chapter.self, database: .psql)
    config.add(model: Sentence.self, database: .psql)
    config.add(model: AccessToken.self, database: .psql)
    config.add(model: RefreshToken.self, database: .psql)
    config.add(model: WordTranslation.self, database: .psql)
    config.add(model: User.self, database: .psql)
    config.add(model: Word.self, database: .psql)
    config.add(model: WordSentence.self, database: .psql)
}
