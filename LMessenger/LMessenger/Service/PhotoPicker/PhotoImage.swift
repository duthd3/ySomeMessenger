//
//  PhotoImage.swift
//  LMessenger
//
//  Created by juni on 3/9/25.
//

import SwiftUI

struct PhotoImage: Transferable {
    let data: Data
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            guard let uiImage = UIImage(data: data) else {
                throw PhotoPickerError.importFailError
            }
            
            guard let data = uiImage.jpegData(compressionQuality: 0.3) else {
                throw PhotoPickerError.importFailError
            }
            
            return PhotoImage(data: data)
        }
    }
}
