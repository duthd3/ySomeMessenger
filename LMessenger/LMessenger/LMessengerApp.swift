//
//  LMessengerApp.swift
//  LMessenger
//
//  Created by juni on 12/28/24.
//

import SwiftUI

@main
struct LMessengerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var container: DIContainer = .init(services: Services())
    var body: some Scene {
        WindowGroup {
            AuthenticatedView(authViewModel: .init(container: container), navigationRouter: .init(), searchDataController: .init())
                .environmentObject(container)
        }
    }
}
