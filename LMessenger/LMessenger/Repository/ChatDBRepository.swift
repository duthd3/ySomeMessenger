//
//  ChatDBRepository.swift
//  LMessenger
//
//  Created by juni on 3/23/25.
//

import Foundation
import Combine
import FirebaseDatabase

protocol ChatDBRepositoryType {
    func addChat(_ object: ChatObject, to chatRoomId: String) -> AnyPublisher<Void, DBError>
    func childByAutoId(chatRoomId: String) -> String // time스탬프 기반 -> 채팅방 시간 순 정렬
    func observeChat(chatRoomId: String) -> AnyPublisher<ChatObject?, DBError> // 채팅 추적 관찰하기
    func removeObservedHandlers()
}

class ChatDBRepository: ChatDBRepositoryType {
    var db: DatabaseReference = Database.database().reference()
    
    var observedHandler: [UInt] = []
    
    func addChat(_ object: ChatObject, to chatRoomId: String) -> AnyPublisher<Void, DBError> {
        Just(object)
            .compactMap { try? JSONEncoder().encode($0) }
            .compactMap { try? JSONSerialization.jsonObject(with: $0, options: .fragmentsAllowed) }
            .flatMap { value in
                Future<Void, Error> { [weak self] promise in
                    self?.db.child(DBKey.Chats).child(chatRoomId).child(object.chatId).setValue(value) { error, _ in
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
    
    func childByAutoId(chatRoomId: String) -> String {
        let ref = db.child(DBKey.Chats).child(chatRoomId).childByAutoId()
        return ref.key ?? ""
    }
    
    func observeChat(chatRoomId: String) -> AnyPublisher<ChatObject?, DBError> {
        let subject = PassthroughSubject<Any?, DBError>() // 채팅은 한번 보내고 스트림이 종료되는게 아니라 계속 관찰을 해야하기 때문에 Future 사용 x
        
        // Chats/chatRoomId
        let handler = db.child(DBKey.Chats).child(chatRoomId).observe(.childAdded) { snapshot in
                subject.send(snapshot.value)
            }
        
        observedHandler.append(handler)
        
        return subject
            .flatMap { value in
                if let value {
                    return Just(value)
                        .tryMap { try JSONSerialization.data(withJSONObject: $0) }
                        .decode(type: ChatObject?.self, decoder: JSONDecoder())
                        .mapError { DBError.error($0) }
                        .eraseToAnyPublisher()
                } else {
                    return Just(nil).setFailureType(to: DBError.self).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func removeObservedHandlers() {
        observedHandler.forEach {
            db.removeObserver(withHandle: $0)
        }
    }
}


