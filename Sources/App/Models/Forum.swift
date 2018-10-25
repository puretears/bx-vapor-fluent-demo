//
//  Forum.swift
//  App
//
//  Created by Mars on 2018/9/22.
//

import Vapor
import Fluent
import Foundation
import FluentMySQL

struct Forum: Content, MySQLModel {
  var id: Int?
  var name: String

  init(id: Int?, name: String) {
    self.id = id
    self.name = name
  }

  init(name: String) {
    self.init(id: nil, name: name)
  }
}
