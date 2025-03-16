//
//  ImageCacheService.swift
//  LMessenger
//
//  Created by juni on 3/9/25.
//

import UIKit
import Combine

protocol ImageCacheServiceType {
    func image(for key: String) -> AnyPublisher<UIImage?, Never>
}

class ImageCacheService: ImageCacheServiceType {
    let memoryStorage: MemoryStorageType
    let diskStorage: DiskStorageType
    
    init(memoryStorage: MemoryStorageType, diskStorage: DiskStorageType) {
        self.memoryStorage = memoryStorage
        self.diskStorage = diskStorage
    }
    
    func image(for key: String) -> AnyPublisher<UIImage?, Never> {
        /*
         1. memory storage 없으면
         2. disk storage 없으면
         3. url session
         */
        imageWithMemoryCache(for: key)
            .flatMap { image -> AnyPublisher<UIImage?, Never> in
                if let image {
                    return Just(image).eraseToAnyPublisher()
                } else {
                    // 메모리 캐시가 없다면 -> 디스크 캐시
                    return self.imageWithDiskCache(for: key)
                }
            }
            .eraseToAnyPublisher()
    }

    func imageWithMemoryCache(for key: String) -> AnyPublisher<UIImage?, Never> {
        Future { [weak self] promise in
            let image = self?.memoryStorage.value(for: key)
            promise(.success(image))
        }.eraseToAnyPublisher()
    }
    
    func imageWithDiskCache(for key: String) -> AnyPublisher<UIImage?, Never> {
        Future<UIImage?, Never> { [weak self] promise in
            do {
                let image = try self?.diskStorage.value(for: key)
                promise(.success(image))
            } catch {
                promise(.success(nil))
            }
        }
        .flatMap { image -> AnyPublisher<UIImage?, Never> in
            if let image {
                return Just(image)
                    .handleEvents(receiveOutput:{ [weak self] image in
                        guard let image else { return }
                        self?.store(for: key, image: image, toDisk: false) // 디스크 캐시에서 가져온 이미지 이기 때문에 디스크에 저장할 필요 없음.
                    })
                    .eraseToAnyPublisher()
            } else {
                // 디스크 캐시가 없다면 -> remote
                return self.remoteImage(for: key)
            }
        }
        .eraseToAnyPublisher()
    }
    
    func remoteImage(for urlString: String) -> AnyPublisher<UIImage?, Never> {
        URLSession.shared.dataTaskPublisher(for: URL(string: urlString)!)
            .map { data, _ in
                UIImage(data: data)
            }
            .replaceError(with: nil)
            .handleEvents(receiveOutput: { [weak self] image in
                guard let image else { return }
                self?.store(for: urlString, image: image, toDisk: true)// 메모리 캐시, 디스크캐시에 모두 저장
            })
            .eraseToAnyPublisher()
    }
    
    func store(for key: String, image: UIImage, toDisk: Bool) {
        memoryStorage.store(for: key, image: image)
        if toDisk {
            // disk 스토리지에 저장
            try? diskStorage.store(for: key, image: image)
        }
    }
}

class StubImageCacheService: ImageCacheServiceType {
    func image(for key: String) -> AnyPublisher<UIImage?, Never> {
        Empty().eraseToAnyPublisher()
    }
}
