//
//  UserService.swift
//  LMessenger
//
//  Created by juni on 2/16/25.
//

import Foundation

protocol UserServiceType {
    
}

class UserService: UserServiceType {
    
    private var dbRepository: UserDBRepositoryType
    
    init(dbRepository: UserDBRepositoryType) {
        self.dbRepository = dbRepository
    }
}

class StubUserService: UserServiceType {
    
}
