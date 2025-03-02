//
//  UserService.swift
//  LMessenger
//
//  Created by juni on 2/16/25.
//

import Foundation
import Combine

protocol UserServiceType {
    func addUser(_ user: User) -> AnyPublisher<User, ServiceError>
    func getUser(userId: String) -> AnyPublisher<User, ServiceError>
    func loadUsers(id: String) -> AnyPublisher<[User], ServiceError> // 유저 정보 가져오기 (친구)
    func addUserAfterContact(users: [User]) -> AnyPublisher<Void, ServiceError> // 연락처에서 친구 데이터베이스로 넣기
}

class UserService: UserServiceType {
    
    private var dbRepository: UserDBRepositoryType
    
    init(dbRepository: UserDBRepositoryType) {
        self.dbRepository = dbRepository
    }
    
    func addUser(_ user: User) -> AnyPublisher<User, ServiceError> {
        dbRepository.addUser(user.toObject()) // user -> userObject
            .map { user }
            .mapError { .error($0) }
            .eraseToAnyPublisher()
    }
    
    func getUser(userId: String) -> AnyPublisher<User, ServiceError> {
        dbRepository.getUser(userId: userId)
            .map { $0.toModel() }
            .mapError { .error($0) }
            .eraseToAnyPublisher()
    }
    
    func loadUsers(id: String) -> AnyPublisher<[User], ServiceError> {
        dbRepository.loadUsers()
            .map { $0
                .map { $0.toModel() }
                .filter { $0.id != id}
            }
            .mapError { .error($0) }
            .eraseToAnyPublisher()
    }
    
    func addUserAfterContact(users: [User]) -> AnyPublisher<Void, ServiceError> {
        dbRepository.addUserAfterContact(users: users.map { $0.toObject()} )
            .mapError { .error($0) }
            .eraseToAnyPublisher()
            
    }

}

class StubUserService: UserServiceType {
    func addUser(_ user: User) -> AnyPublisher<User, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
    
    func getUser(userId: String) -> AnyPublisher<User, ServiceError> {
        Just(.stub1).setFailureType(to: ServiceError.self).eraseToAnyPublisher()
    }
    
    func loadUsers(id: String) -> AnyPublisher<[User], ServiceError> {
        Just([.stub1, .stub2]).setFailureType(to: ServiceError.self).eraseToAnyPublisher()
    }
    
    func addUserAfterContact(users: [User]) -> AnyPublisher<Void, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
    

}
