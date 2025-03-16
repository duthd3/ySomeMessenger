//
//  MemoryStorage.swift
//  LMessenger
//
//  Created by juni on 3/9/25.
//

import Foundation
import UIKit

protocol MemoryStorageType {
    func value(for key: String) -> UIImage?
    func store(for key: String, image: UIImage)
}

class MemoryStorage: MemoryStorageType {
    var cache = NSCache<NSString, UIImage>()
    
    func value(for key: String) -> UIImage? {
        cache.object(forKey: NSString(string: key))
    }
    
    func store(for key: String, image: UIImage) {
        cache.setObject(image, forKey: NSString(string: key))
    }
}
