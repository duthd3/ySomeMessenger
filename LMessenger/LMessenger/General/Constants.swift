//
//  Constants.swift
//  LMessenger
//
//  Created by juni on 2/16/25.
//

import Foundation

typealias DBKey = Constants.DBKey
typealias AppStorageType = Constants.AppStorage

enum Constants {
    
}

extension Constants {
    struct DBKey {
        static let Users = "Users"
        static let ChatRooms = "ChatRooms"
        static let Chats = "Chats"
    }
}

extension Constants {
    struct AppStorage {
        static let Appearance = "AppStorarge_Appearance"
    }
}

