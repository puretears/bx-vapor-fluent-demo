//
// Created by Mars on 2018/9/29.
//
import Vapor
import Fluent
import Foundation
import FluentMySQL

struct MessageSeeder: Migration {
  typealias Database = MySQLDatabase

  static func prepare(on connection: Database.Connection) -> Future<Void> {
    var messageId = 0

    return [1, 2, 3].flatMap {
      forum in
      return [1, 2, 3, 4, 5].map {
        message -> Message in
        messageId += 1
        let title = "Title \(message) in Forum \(forum)"
        let content = "Body of Title \(message)"
        let originId = message > 3 ? (forum * 5 - 4) : 0
        return Message(
          id: messageId,
          forumId: forum,
          title: title,
          content: content,
          originId: originId,
          author: "bx11",
          createdAt: Date())
        }
      }
      .map { $0.create(on: connection) }
      .flatten(on: connection)
      .transform(to: ())
  }
  
  static func revert(on conn: Database.Connection) -> Future<Void> {
    return conn.query("truncate table `Message`").transform(to: Void())
  }
}
