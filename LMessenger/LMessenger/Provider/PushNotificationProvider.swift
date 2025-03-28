//
//  PushNotificationProvider.swift
//  LMessenger
//
//  Created by juni on 3/23/25.
//

import Foundation
import Combine

protocol PushNotificationProviderType {
    func sendPushNotification(object: PushObject) -> AnyPublisher<Bool, Never>
}

class PushNotificationProvider: PushNotificationProviderType {
    private let serverURL: URL = URL(string: "https://fcm.googleapis.com/v1/projects/lmessenger-ffacb/messages:send")!
    private let serverKey = "ya29.a0AeXRPp7qC7MvgUNMe2yEeI5zFgRSPhbBJ6CgxfVnDOp3tt3uYygaC5uH7c2ay8I_d7w3-Wckq-1VLhps2y3mHSvVgsJX4gg23Ro-UalyeWqX7nLEW4guyFhUWB4cpKB4pQjHVBpWpcaZSYxqCNyx7rwoRgj3IzAe1rKAwgRHaCgYKAaoSARISFQHGX2Miicps53L0YrOjKlgSXOuEYA0175"
    
    func sendPushNotification(object: PushObject) -> AnyPublisher<Bool, Never> {
        var request = URLRequest(url: serverURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(("Bearer \(serverKey)"), forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONEncoder().encode(object)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { _ in true }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
}
