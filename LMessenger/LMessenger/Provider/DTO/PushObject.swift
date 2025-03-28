//
//  PushObject.swift
//  LMessenger
//
//  Created by juni on 3/23/25.
//

import Foundation

struct PushObject: Encodable {
    var message: Message
    
    struct Message: Encodable {
        var token: String
        var notification: NotificationObject
    }
    
    struct NotificationObject: Encodable {
        var body: String
        var title: String
    }
}

