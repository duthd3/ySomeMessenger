//
//  User.swift
//  LMessenger
//
//  Created by juni on 1/1/25.
//

import Foundation

struct User: Encodable {
    var id: String
    var name: String
    var phoneNumber: String?
    var profileURL: String?
    var description: String?
}

extension User {
    static var stub1: User {
        .init(id: "user1_id", name: "정혜인")
    }
    static var stub2: User {
        .init(id: "user2_id", name: "윤여송")
    }
}

extension User {
    func toObject() -> UserObject {
        .init(id: id, 
              name: name,
              phoneNumber: phoneNumber,
              profileURL: profileURL,
              description: description)
    }
}
