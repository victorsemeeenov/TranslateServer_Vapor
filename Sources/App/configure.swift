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
    
    registerPostgreSQLRepository(&services, config: &config)
    
    //Configure a Transaction
    services.register(PostgreeSQLTransaction.self)

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

private func registerPostgreSQLRepository(_ services: inout Services, config: inout Config) {
    services.register(PostgreSQLRepository<Author>.self)
    services.register(PostgreSQLRepository<Book>.self)
    services.register(PostgreSQLRepository<Chapter>.self)
    services.register(PostgreSQLRepository<Sentence>.self)
    services.register(PostgreSQLRepository<AccessToken>.self)
    services.register(PostgreSQLRepository<RefreshToken>.self)
    services.register(PostgreSQLRepository<Translation>.self)
    services.register(PostgreSQLRepository<User>.self)
    services.register(PostgreSQLRepository<Word>.self)
    
    config.prefer(PostgreSQLRepository<Author>.self, for: AbstractRepository<Author>.self)
    config.prefer(PostgreSQLRepository<Book>.self, for: AbstractRepository<Book>.self)
    config.prefer(PostgreSQLRepository<Chapter>.self, for: AbstractRepository<Chapter>.self)
    config.prefer(PostgreSQLRepository<Sentence>.self, for: AbstractRepository<Sentence>.self)
    config.prefer(PostgreSQLRepository<AccessToken>.self, for: AbstractRepository<AccessToken>.self)
    config.prefer(PostgreSQLRepository<RefreshToken>.self, for: AbstractRepository<RefreshToken>.self)
    config.prefer(PostgreSQLRepository<Translation>.self, for: AbstractRepository<Translation>.self)
    config.prefer(PostgreSQLRepository<User>.self, for: AbstractRepository<User>.self)
    config.prefer(PostgreSQLRepository<Word>.self, for: AbstractRepository<Word>.self)
}
