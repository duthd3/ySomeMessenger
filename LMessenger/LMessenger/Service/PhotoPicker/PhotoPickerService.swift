//
//  PhotoPickerService.swift
//  LMessenger
//
//  Created by juni on 3/9/25.
//

import Foundation
import PhotosUI
import SwiftUI
import Combine

enum PhotoPickerError: Error {
    case importFailError
}

protocol PhotoPickerServiceType {
    func loadTransferable(from imageSelection: PhotosPickerItem) async throws -> Data // 가져온 사진 데이터 파이어베이스로 넘기기 위해서 이미지 데이터화 시키기
    func loadTransferable(from imageSelection: PhotosPickerItem) -> AnyPublisher<Data, ServiceError> // combine 활용 
}

class PhotoPickerService: PhotoPickerServiceType {
    func loadTransferable(from imageSelection: PhotosPickerItem) async throws -> Data {
        guard let image = try await imageSelection.loadTransferable(type: PhotoImage.self) else {
            throw PhotoPickerError.importFailError
        }
        return image.data
    }
    
    func loadTransferable(from imageSelection: PhotosPickerItem) -> AnyPublisher<Data, ServiceError> {
        Future { promise in
            imageSelection.loadTransferable(type: PhotoImage.self) { result in
                switch result {
                case let.success(image):
                    guard let data = image?.data else {
                        promise(.failure(PhotoPickerError.importFailError))
                        return
                    }
                    promise(.success(data))
                case let .failure(error):
                    promise(.failure(error))
                }
            }
        }
        .mapError { .error($0) }
        .eraseToAnyPublisher()
    }
}

class StubPhotoPickerService: PhotoPickerServiceType {
    func loadTransferable(from imageSelection: PhotosPickerItem) async throws -> Data {
        return Data()
    }
    
    func loadTransferable(from imageSelection: PhotosPickerItem) -> AnyPublisher<Data, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
}
