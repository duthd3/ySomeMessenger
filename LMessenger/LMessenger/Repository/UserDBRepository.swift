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
    func addUser(_ object: UserObject) -> AnyPublisher<Void, DBError> // 사용자 정보 DB에 저장
    func getUser(userId: String) -> AnyPublisher<UserObject, DBError> // DB에서 사용자 정보 가져오기
    func getUser(userId: String) async throws -> UserObject // async로 비동기로 작업하기
    func updateUser(userId: String, key: String, value: Any) async throws // 유저 정보 업데이트
    func updateUser(id: String, key: String, value: Any) -> AnyPublisher<Void, DBError>
    func loadUsers() -> AnyPublisher<[UserObject], DBError> // 유저 정보 DB에서 가져오기
    func addUserAfterContact(users: [UserObject]) -> AnyPublisher<Void, DBError>
    func filterUsers(with queryString: String) -> AnyPublisher<[UserObject], DBError>
}

class UserDBRepository: UserDBRepositoryType {
    
    var db: DatabaseReference = Database.database().reference() // firebase database root
    
    func addUser(_ object: UserObject) -> AnyPublisher<Void, DBError> {
        // dictionary 형태로 data를 저장
        // object > data > dict
        Just(object)
            .compactMap {
                try? JSONEncoder().encode($0)
            }
            .compactMap { try? JSONSerialization.jsonObject(with: $0, options: .fragmentsAllowed) }
            .flatMap { value in
                Future<Void, Error> { [weak self] promise in // Users/userId/ ..
                    self?.db.child(DBKey.Users).child(object.id).setValue(value) { error, _ in // USers Key -> id -> value 저장
                        if let error {
                            promise(.failure(error))
                        } else {
                            promise(.success(()))
                        }
                    }
                }
            }
            .mapError { DBError.error($0) }
            .eraseToAnyPublisher()
    }
    
    func getUser(userId: String) -> AnyPublisher<UserObject, DBError> {
        Future<Any?, DBError> { [weak self] promise in
            self?.db.child(DBKey.Users).child(userId).getData { error, snapshot in
                if let error {
                    promise(.failure(DBError.error(error)))
                } else if snapshot?.value is NSNull { // nil이 아님
                    promise(.success(nil))
                } else {
                    print("======유저 정보======: \(snapshot?.value)")
                    promise(.success(snapshot?.value)) // dict 형태
                }
            }
        }.flatMap { value in
            if let value {
                return Just(value)
                    .tryMap { try JSONSerialization.data(withJSONObject: $0) }
                    .decode(type: UserObject.self, decoder: JSONDecoder())
                    .mapError { DBError.error($0) }
                    .eraseToAnyPublisher()
            } else {
                return Fail(error: DBError.emptyValue).eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getUser(userId: String) async throws -> UserObject {
        guard let value = try await self.db.child(DBKey.Users).child(userId).getData().value else {
            throw DBError.emptyValue
        }
        
        let data = try JSONSerialization.data(withJSONObject: value)
        let userObject = try JSONDecoder().decode(UserObject.self, from: data)
        return userObject
    }
    
    func updateUser(userId: String, key: String, value: Any) async throws {
        try await self.db.child(DBKey.Users).child(userId).child(key).setValue(value)
    }
    
    func loadUsers() -> AnyPublisher<[UserObject], DBError> {
        Future<Any?, DBError> { [weak self] promise in
            self?.db.child(DBKey.Users).getData { error, snapshot in
                if let error {
                    promise(.failure(DBError.error(error)))
                } else if snapshot?.value is NSNull {
                    promise(.success(nil))
                } else {
                    promise(.success(snapshot?.value)) // dict 형태
                }
            }
        }.flatMap { value in
            if let dic = value as? [String: [String: Any]] { // 형태가 맞다면
                return Just(dic)
                    .tryMap { try JSONSerialization.data(withJSONObject: $0) }
                    .decode(type: [String: UserObject].self, decoder: JSONDecoder())
                    .map { $0.values.map { $0 as UserObject } }
                    .mapError { DBError.error($0) }
                    .eraseToAnyPublisher()
            } else if value == nil {
                return Just([]).setFailureType(to: DBError.self).eraseToAnyPublisher()
            } else { // 실패할 경우
                return Fail(error: .invalidatedType).eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
    
    func addUserAfterContact(users: [UserObject]) -> AnyPublisher<Void, DBError> {
        /*
         Users/
            user_id: [String: Any]
            user_id: [String: Any]
            ...
         */
        Publishers.Zip(users.publisher, users.publisher)
            .compactMap { origin, converted in
                if let converted = try? JSONEncoder().encode(converted) {
                    return (origin, converted)
                } else {
                    return nil
                }
            }
            .compactMap { origin, converted in
                if let converted = try? JSONSerialization.jsonObject(with: converted, options: .fragmentsAllowed) {
                    return (origin, converted)
                } else {
                    return nil
                }
            }
            .flatMap { origin, converted in
                Future<Void, Error> { [weak self] promise in
                    self?.db.child(DBKey.Users).child(origin.id).setValue(converted) { error, _ in
                        if let error {
                            promise(.failure(error))
                        } else {
                            promise(.success(()))
                        }
                    }
                }
            }
            .last()
            .mapError { .error($0) }
            .eraseToAnyPublisher()
    }
    
    func updateUser(id: String, key: String, value: Any) -> AnyPublisher<Void, DBError> {
        Future<Void, Error> { [weak self] promise in
            self?.db.child(DBKey.Users).child(id).child(key).setValue(value) { error, _ in
                if let error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .mapError { DBError.error($0) }
        .eraseToAnyPublisher()
    }
    
    func filterUsers(with queryString: String) -> AnyPublisher<[UserObject], DBError> {
        Future { [weak self] promise in
            self?.db.child(DBKey.Users)
                .queryOrdered(byChild: "name") // 이름순으로 정렬
                .queryStarting(atValue: queryString)
                .queryEnding(atValue: queryString + "\u{f88f}")
                .observeSingleEvent(of: .value) { snapshot in
                    promise(.success(snapshot.value))
                } // [String: [String: Any]]
        }.flatMap { value in
            
            if let dic = value as? [String: [String: Any]] {
                return Just(dic)
                    .tryMap { try JSONSerialization.data(withJSONObject: $0)}
                    .decode(type: [String: UserObject].self, decoder: JSONDecoder())
                    .map { $0.values.map { $0 as UserObject }}
                    .mapError { DBError.error($0)}
                    .eraseToAnyPublisher()
            } else if value == nil {
                return Just([]).setFailureType(to: DBError.self).eraseToAnyPublisher()
            } else {
                return Fail(error: .invalidatedType).eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
}
