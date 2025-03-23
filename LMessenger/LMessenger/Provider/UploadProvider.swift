//
//  Upload.swift
//  LMessenger
//
//  Created by juni on 3/9/25.
//

import Foundation
import Combine
import FirebaseStorage
import FirebaseStorageCombineSwift

enum UploadError: Error {
    case error(Error)
}

protocol UploadProviderType {
    func upload(path: String, data: Data, fileName: String) async throws -> URL
    func upload(path: String, data: Data, fileName: String) -> AnyPublisher<URL, UploadError>
}

class UploadProvider: UploadProviderType {
    
    let storageRef = Storage.storage().reference() // storage 주소 가져오기
    
    func upload(path: String, data: Data, fileName: String) async throws -> URL {
        let ref = storageRef.child(path).child(fileName)
        let _ = try await ref.putDataAsync(data)
        let url = try await ref.downloadURL()
        
        return url
    }
    
    func upload(path: String, data: Data, fileName: String) -> AnyPublisher<URL, UploadError> {
        let ref = storageRef.child(path).child(fileName)
        
        return ref.putData(data)
            .flatMap { _ in
                ref.downloadURL()
            }
            .mapError { .error($0) }
            .eraseToAnyPublisher()
    }
}
