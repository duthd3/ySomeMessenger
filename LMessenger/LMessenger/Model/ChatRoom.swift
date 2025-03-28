//
//  ChatRoom.swift
//  LMessenger
//
//  Created by juni on 3/16/25.
//

import Foundation

struct ChatRoom: Hashable {
    var chatRoomId: String
    var lastMessage: String?
    var otherUserName: String
    var otherUserId: String
}


extension ChatRoom {
    func toObject() -> ChatRoomObject {
        .init(chatRoomId: chatRoomId, lastMessage: lastMessage, otherUserName: otherUserName, otherUserId: otherUserId)
    }
    
    static var stub1: ChatRoom {
        .init(chatRoomId: "id1", otherUserName: "other_user_name1", otherUserId: "other_user_id1")
    }
    static var stub2: ChatRoom {
        .init(chatRoomId: "id2", otherUserName: "other_user_name2", otherUserId: "otheer_user_id2")
    }
}
