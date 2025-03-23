//
//  ChatData.swift
//  LMessenger
//
//  Created by juni on 3/19/25.
//
 
import Foundation

struct ChatData: Hashable, Identifiable {
    var dateStr: String
    var chats: [Chat]
    var id: String { dateStr }
}
