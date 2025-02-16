//
//  UserDBRepository.swift
//  LMessenger
//
//  Created by juni on 2/16/25.
//

import Foundation
import Combine
import FirebaseDatabase

protocol UserDBRepositoryType {
    func addUser(_ object: User)
}

class UserDBRepository: UserDBRepositoryType {
    
}
