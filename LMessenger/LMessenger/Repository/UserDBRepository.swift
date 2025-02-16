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
}
