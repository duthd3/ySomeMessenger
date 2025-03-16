//
//  PhotoPickerService.swift
//  LMessenger
//
//  Created by juni on 3/9/25.
//

import Foundation
import PhotosUI
import SwiftUI

enum PhotoPickerError: Error {
    case importFailError
}

protocol PhotoPickerServiceType {
    func loadTransferable(from imageSelection: PhotosPickerItem) async throws -> Data // 가져온 사진 데이터 파이어베이스로 넘기기 위해서 이미지 데이터화 시키기
}

class PhotoPickerService: PhotoPickerServiceType {
    func loadTransferable(from imageSelection: PhotosPickerItem) async throws -> Data {
        guard let image = try await imageSelection.loadTransferable(type: PhotoImage.self) else {
            throw PhotoPickerError.importFailError
        }
        return image.data
    }
}

class StubPhotoPickerService: PhotoPickerServiceType {
    func loadTransferable(from imageSelection: PhotosPickerItem) async throws -> Data {
        return Data()
    }
}
