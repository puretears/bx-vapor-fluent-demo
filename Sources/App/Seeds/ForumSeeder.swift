//
// Created by Mars on 2018/9/29.
//

import Fluent
import Foundation
import FluentMySQL

struct ForumSeeder: Migration {
  typealias Database = MySQLDatabase

  static func prepare(on connection: Database.Connection) -> Future<Void> {

    return [1, 2, 3]
      .map { i in
        Forum(name: "Forum \(i!)")

      }
      .map { $0.save(on: connection) }
      .flatten(on: connection)
      .transform(to: ())
  }
    
    static func revert(on conn: Database.Connection) -> Future<Void> {
      return conn.query("truncate table `Forum`").transform(to: Void())
    }
}
