//
//  HomeViewModel.swift
//  LMessenger
//
//  Created by juni on 2/9/25.
//

import Foundation

class HomeViewModel: ObservableObject {
    @Published var myUser: User?
    @Published var users: [User] = [.stub1, .stub2]
    
}
