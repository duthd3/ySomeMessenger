//
//  MyProfileViewModel.swift
//  LMessenger
//
//  Created by juni on 3/9/25.
//

import Foundation
import PhotosUI
import SwiftUI

@MainActor
class MyProfileViewModel: ObservableObject {
    
    @Published var userInfo: User?
    @Published var isPresentedDescEditView: Bool = false
    @Published var imageSelection: PhotosPickerItem? {
        didSet {
            print("imageSelection완료!")
            Task {
                await updateProfileImage(pickerItem: imageSelection)
            }
        }
    }
    
    private var container: DIContainer
    private let userId: String
    
    init(container: DIContainer, userId: String) {
        self.container = container
        self.userId = userId
    }
    
    func getUser() async {
        if let user = try? await container.services.userService.getUser(userId: userId) {
            userInfo = user
        }
    }
    
    func updateDescription(_ description: String) async {
        do {
            try await container.services.userService.updateDescription(userId: userId, description: description)
            userInfo?.description = description
        } catch {
            
        }
    }
    
    func updateProfileImage(pickerItem: PhotosPickerItem?) async {
        guard let pickerItem else {
            return
        }
        do {
            let data = try await container.services.photoPickerService.loadTransferable(from: pickerItem) //이미지 data화
            let url = try await container.services.uploadService.uploadImage(source: .profile(userId: userId), data: data) // 이미지 업로드
            try await container.services.userService.updateProfileURL(userId: userId, urlString: url.absoluteString) // db업데이트
            
            userInfo?.profileURL = url.absoluteString
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
