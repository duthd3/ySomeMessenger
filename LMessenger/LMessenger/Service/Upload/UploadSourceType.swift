//
//  UploadSourceType.swift
//  LMessenger
//
//  Created by juni on 3/9/25.
//

import Foundation

enum UploadSourceType {
    case chat(chatRoomId: String)
    case profile(userId: String)
    
    var path: String {
        switch self {
        case let .chat(chatRoomId): // Chats/chatRoomId/
            return "\(DBKey.Chats)/\(chatRoomId)"
        case let .profile(userId): // USers/UserId/
            return "\(DBKey.Users)/\(userId)"
        }
    }
}
