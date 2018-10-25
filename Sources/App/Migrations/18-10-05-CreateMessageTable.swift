//
// Created by Mars on 2018/9/28.
//

import Fluent
import FluentMySQL

extension Message: Migration {
  static func prepare(on connection: MySQLConnection) -> Future<Void> {
    return Database.create(Message.self, on: connection) {
      builder in
      try addProperties(to: builder)
    }
  }

  static func revert(on connection: MySQLConnection) -> Future<Void> {
    return Database.delete(Message.self, on: connection)
  }
}
