import Vapor
import Fluent
import FluentMySQL

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
  /// Register providers first
  try services.register(FluentMySQLProvider())

  /// Register routes to the router
  let router = EngineRouter.default()
  try routes(router)
  services.register(router, as: Router.self)

  /// Register middleware
  var middlewares = MiddlewareConfig() // Create _empty_ middleware config
  /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
  middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
  services.register(middlewares)

  let mysqlHost: String
  let mysqlPort: Int
  let mysqlDB: String
  let mysqlUser: String
  let mysqlPass: String

  if env == .development || env == .testing {
    mysqlHost = "mysql"
    mysqlPort = 3306
    mysqlDB = "vapor"
    mysqlUser = "vapor"
    mysqlPass = "vapor"
  }
  else {
    print("Under production env")
    mysqlHost = Environment.get("MYSQL_HOST") ?? "vapor"
    mysqlPort = 3306
    mysqlDB = Environment.get("MYSQL_DB") ?? "vapor"
    mysqlUser = Environment.get("MYSQL_USER") ?? "vapor"
    mysqlPass = Environment.get("MYSQL_PASS") ?? "vapor"
  }

  /// Register the configured MySQL database to the database config.
  var databases = DatabasesConfig()

  let mysqlConfig = MySQLDatabaseConfig(
    hostname: mysqlHost,
    port: mysqlPort,
    username: mysqlUser,
    password: mysqlDB,
    database: mysqlPass,
    transport: .unverifiedTLS)
  let mysql = MySQLDatabase(config: mysqlConfig)

  databases.add(database: mysql, as: .mysql)
  services.register(databases)

  Forum.defaultDatabase = .mysql

  /// Configure migrations
  var migrations = MigrationConfig()
  migrations.add(model: Forum.self, database: .mysql)
  migrations.add(model: Message.self, database: .mysql)
//  migrations.add(model: User.self, database: .mysql)

  if env == .development {
    migrations.add(migration: ForumSeeder.self, database: .mysql)
    migrations.add(migration: MessageSeeder.self, database: .mysql)
  }
  services.register(migrations)

  // Configure the rest of your application here
  var commandConfig = CommandConfig.default()
  commandConfig.useFluentCommands()
  services.register(commandConfig)
}
