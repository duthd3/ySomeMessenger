//
//  OtherProfileViewModel.swift
//  LMessenger
//
//  Created by juni on 3/16/25.
//

import Foundation

class OtherProfileViewModel: ObservableObject {
    @Published var userInfo: User?
    
    private let userId: String
    private let container: DIContainer
    
    init(container: DIContainer, userId: String) {
        self.container = container
        self.userId = userId
        
    }
    
    func getUser() async {
        if let user = try? await container.services.userService.getUser(userId: userId) {
            userInfo = user
        }
    }
}
