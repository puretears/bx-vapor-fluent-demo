//
// Created by Mars on 2018/9/26.
//

import Vapor
import Fluent
import Foundation
import FluentMySQL

struct Message: Content, MySQLModel {
  var id: Int?
  var forumId: Int
  var title: String
  var content: String
  var originId: Int
  var author: String
  var createdAt: Date
}

