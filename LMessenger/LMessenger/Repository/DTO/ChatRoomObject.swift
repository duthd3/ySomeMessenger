//
//  ChatRoomObject.swift
//  LMessenger
//
//  Created by juni on 3/16/25.
//

import Foundation

struct ChatRoomObject: Codable {
    var chatRoomId: String
    var lastMessage: String?
    var otherUserName: String
    var otherUserID: String
}

extension ChatRoomObject {
    func toModel() -> ChatRoom {
        .init(chatRoomId: chatRoomId, lastMessage: lastMessage, otherUserName: otherUserName, otherUserId: otherUserID)
    }
}
