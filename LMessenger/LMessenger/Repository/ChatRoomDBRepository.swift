//
//  ChatRoomDbRepository.swift
//  LMessenger
//
//  Created by juni on 3/16/25.
//

import Foundation
import Combine
import FirebaseDatabase

protocol ChatRoomDBRepositoryType {
    func getChatRoom(myUserId: String, otherUserId: String) -> AnyPublisher<ChatRoomObject?, DBError>
    func addChatRoom(_ object: ChatRoomObject, myUserId: String) -> AnyPublisher<Void, DBError>
    func loadChatRooms(myUserId: String) -> AnyPublisher<[ChatRoomObject], DBError>
    func updateChatRoomLastMessage(chatRoomId: String, myUserId: String, myUserName: String, otherUserId: String, lastMessage: String) -> AnyPublisher<Void, DBError>
}

class ChatRoomDBRepository: ChatRoomDBRepositoryType {
    
    var db: DatabaseReference = Database.database().reference()
    
    // 채팅방이 존재하는지 -> 가져오기
    func getChatRoom(myUserId: String, otherUserId: String) -> AnyPublisher<ChatRoomObject?, DBError> {
        Future<Any?, DBError> { [weak self] promise in
            self?.db.child(DBKey.ChatRooms).child(myUserId).child(otherUserId).getData { error, snapshot in
                if let error {
                    promise(.failure(DBError.error(error)))
                } else if snapshot?.value is NSNull {
                    promise(.success(nil))
                } else {
                    promise(.success(snapshot?.value))
                }
            }
        }
        .flatMap { value in
            if let value {
                return Just(value)
                    .tryMap { try JSONSerialization.data(withJSONObject: $0) }
                    .decode(type: ChatRoomObject?.self, decoder: JSONDecoder())
                    .mapError { DBError.error($0) }
                    .eraseToAnyPublisher()
            } else {
                return Just(nil).setFailureType(to: DBError.self).eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
    // 채팅방 추가하기
    func addChatRoom(_ object: ChatRoomObject, myUserId: String) -> AnyPublisher<Void, DBError> {
        Just(object)
            .compactMap { try? JSONEncoder().encode($0) }
            .compactMap { try? JSONSerialization.jsonObject(with: $0, options: .fragmentsAllowed)}
            .flatMap { value in
                Future<Void, Error> { [weak self] promise in
                    self?.db.child(DBKey.ChatRooms).child(myUserId).child(object.otherUserId).setValue(value) { error, _ in
                        if let error {
                            promise(.failure(error))
                        } else {
                            promise(.success(()))
                        }
                    }
                }
            }
            .mapError { DBError.error($0)}
            .eraseToAnyPublisher()
    }
    
    // 채팅방 load
    func loadChatRooms(myUserId: String) -> AnyPublisher<[ChatRoomObject], DBError> { // 성공시 chatRoomObject 배열 반환
        Future<Any?, DBError> { [weak self] promise in // Future -> 비동기 작업을 수행하고 한번만 값을 방출하는 Publisher, promise -> 데이터를 가져와서 .success(value) 또는 .failure(error)로 방출
            self?.db.child(DBKey.ChatRooms).child(myUserId).getData { error, snapshot in
                if let error {
                    promise(.failure(DBError.error(error)))
                } else if snapshot?.value is NSNull {
                    promise(.success(nil))
                } else {
                    promise(.success(snapshot?.value))
                }
            }
        }
        .flatMap { value in // 가져온 데이터 변환하기. Future에서 받은 value 변환. flatMap을 사용하여 값이 Publisher로 변환됨
            if let dic = value as? [String: [String: Any]] {
                return Just(dic)
                    .tryMap { try JSONSerialization.data(withJSONObject: $0) }
                    .decode(type: [String: ChatRoomObject].self, decoder: JSONDecoder())
                    .map { $0.values.map { $0 as ChatRoomObject }}
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
    
    func updateChatRoomLastMessage(chatRoomId: String, myUserId: String, myUserName: String, otherUserId: String, lastMessage: String) -> AnyPublisher<Void, DBError> {
        Future { [weak self] promise in
            let values = [
                "\(DBKey.ChatRooms)/\(myUserId)/\(otherUserId)/lastMessage" : lastMessage,
                "\(DBKey.ChatRooms)/\(otherUserId)/\(myUserId)/lastMessage" : lastMessage,
                "\(DBKey.ChatRooms)/\(otherUserId)/\(myUserId)/chatRoomId" : chatRoomId,
                "\(DBKey.ChatRooms)/\(otherUserId)/\(myUserId)/otherUserName" : myUserName,
                "\(DBKey.ChatRooms)/\(otherUserId)/\(myUserId)/otherUserId" : myUserId,
            ]
            
            self?.db.updateChildValues(values) { error, _ in
                if let error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .mapError { .error($0) }
        .eraseToAnyPublisher()
    }
}
