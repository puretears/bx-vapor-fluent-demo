//
// Created by Mars on 2018/10/8.
//
import Fluent
import FluentMySQL
import Foundation

extension User: Migration {
  static func prepare(on connection: MySQLConnection) -> Future<Void> {
    return Database.create(User.self, on: connection) {
      builder in
      try addProperties(to: builder)
    }
  }

  static func revert(on connection: MySQLConnection) -> Future<Void> {
    return Database.delete(User.self, on: connection)
  }
}
