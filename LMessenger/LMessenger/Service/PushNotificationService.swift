//
//  PushNotificationService.swift
//  LMessenger
//
//  Created by juni on 3/23/25.
//

import Foundation
import FirebaseMessaging
import Combine

protocol PushNotificationServiceType {
    var fcmToken: AnyPublisher<String?, Never> { get }
    func requestAuthorization(completion: @escaping (Bool) -> Void)
    func sendPushNotification(fcmToken: String, message: String) -> AnyPublisher<Bool, Never>
}

class PushNotificationService: NSObject, PushNotificationServiceType {
    var provider: PushNotificationProviderType
    
    var fcmToken: AnyPublisher<String?, Never> {
        _fcmToken.eraseToAnyPublisher()
    }
    private let _fcmToken = CurrentValueSubject<String?, Never>(nil)
    init(provider: PushNotificationProviderType) {
        self.provider = provider
        super.init()
        Messaging.messaging().delegate = self
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let authOptoins: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptoins) { granted, error in
            if error != nil {
                completion(false)
            } else {
                completion(granted)
            }
        }
    }
    
    func sendPushNotification(fcmToken: String, message: String) -> AnyPublisher<Bool, Never> {
        provider.sendPushNotification(object: PushObject(message: PushObject.Message(token: fcmToken, notification: PushObject.NotificationObject(body: "test", title: "test"))))
    }
}

extension PushNotificationService: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("messaging:didReceiveRegistrationToken:", fcmToken ?? "")
        
        guard let fcmToken else { return }
        _fcmToken.send(fcmToken)
    }
}

class StubPushNotificationService: PushNotificationServiceType {
    var fcmToken: AnyPublisher<String?, Never> {
        Empty().eraseToAnyPublisher()
    }
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        
    }
    
    func sendPushNotification(fcmToken: String, message: String) -> AnyPublisher<Bool, Never> {
        Empty().eraseToAnyPublisher()
    }
}
 
