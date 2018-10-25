//
//  User.swift
//  App
//
//  Created by Mars on 2018/10/8.
//

import Vapor
import Fluent
import FluentMySQL
import Foundation

struct User: Content, MySQLModel {
  var id: Int?
  var email: String
  var password: String
}
