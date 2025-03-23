//
//  NavigationDestination.swift
//  LMessenger
//
//  Created by juni on 3/16/25.
//

import Foundation

enum NavigationDestination: Hashable {
    case chat(chatRoomId: String, myUserId: String, otherUserId: String)
    case search
}
