import Vapor
import Fluent
import Crypto
import FluentMySQL

struct UserContext: Codable, Content {
  var username: String?
  var forums: [Forum]
}

func getUsername(of: Request) -> String? {
  return "bx11"
}

struct MessageContext: Codable, Content {
  var username: String?
  var forum: Forum
  var messages: [Message]
}

struct ReplyContext: Codable, Content {
  var username: String?
  var forum: Forum
  var message: Message
  var replies: [Message]
}

/// Register your application's routes here.
public func routes(_ router: Router) throws {
  router.get("forums") {
    req -> Future<Response> in

    return Forum.query(on: req).all() // Future<[Forum]>
      .map(to: UserContext.self) { forums -> UserContext in
          return UserContext(username: getUsername(of: req), forums: forums)
      }
      .encode(status: .ok, for: req)
  }

  router.group("users") {
    group in
    group.post("create") {
      req -> Future<Response> in
      var user = try req.content.syncDecode(User.self)

      return User.query(on: req).filter(\.email == user.email).first().flatMap(to: Response.self) {
        userExist in
        guard userExist == nil else {
          throw Abort(HTTPStatus.badRequest)
        }
        
        user.password = try BCrypt.hash(user.password)
        return user.save(on: req).encode(status: .created, for: req)
      }
    }

    group.post(User.self, at: "login") {
      req, user -> Future<Response> in
      return User.query(on: req).filter(\.email == user.email).first().map {
        userExist -> Int in
        guard userExist != nil else { throw Abort(.notFound) }
        
        return 1
      }.encode(status: .ok, for: req)
    }
  }

  router.group("forums", Int.parameter) {
    group in
    
    group.get("messages") {
      req -> Future<Response> in
      let forumId = try req.parameters.next(Int.self)
      
      return Forum.find(forumId, on: req).flatMap(to: Response.self) {
        forum in
        guard let forum = forum else { throw Abort(.notFound) }

        return Message.query(on: req)
          .filter(\.forumId == forum.id!)
          .filter(\.originId == 0)
          .all()
          .map {
            return MessageContext(username: "bx11", forum: forum, messages: $0)
          }
          .encode(status: .ok, for: req)
        }
    }

    group.get("messages", Int.parameter) {
      req -> Future<Response> in
      let fid = try req.parameters.next(Int.self)
      let mid = try req.parameters.next(Int.self)

      return Forum.find(fid, on: req).flatMap(to: Response.self) {
        forum in
        guard let forum = forum else { throw Abort(.notFound) }
        
        return Message.find(mid, on: req).flatMap(to: Response.self) {
          message in
          guard let message = message else { throw Abort(.notFound) }
          
          return Message.query(on: req)
            .filter(\.originId == message.id!)
            .all()
            .map {
              return ReplyContext(username: "bx11", forum: forum, message: message, replies: $0)
            }
            .encode(status: .ok, for: req)
        }
      }
    }
  }
}
