//
//  HomeViewModel.swift
//  LMessenger
//
//  Created by juni on 2/9/25.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    
    enum Action {
        case load
        case presentMyProfileView
        case presentOtherProfileView(String)
        case requestContacts
        case presentView(HomeModalDestination)
        case goToChat(User)
    }
    
    @Published var myUser: User?
    @Published var users: [User] = []
    @Published var phase: Phase = .notRequested
    @Published var modalDestination: HomeModalDestination?
    @Published var otherUser: User?
    
    var userId: String
    
    private var container: DIContainer
    private var navigationRouter: NavigationRouter
    private var subscriptions = Set<AnyCancellable>()
    
    init(container: DIContainer, navigationRouter: NavigationRouter, userId: String) {
        self.container = container
        self.navigationRouter = navigationRouter
        self.userId = userId
    }
    
    func send(action: Action) {
        switch action {
        case .load:
            phase = .loading
            // TODO: 유저 정보 가져오기
            container.services.userService.getUser(userId: userId) // getUser 완료 후 -> loadUser(친구목록 가져오기)
                .handleEvents(receiveOutput: { [weak self] user in
                    self?.myUser = user
                    print("---\(user)")
                })
                .flatMap { user in
                    self.container.services.userService.loadUsers(id: user.id)
                }
                .sink { [weak self] completion in
                    print(completion)
                    print("failure")
                    if case .failure = completion {
                        
                        self?.phase = .fail
                    }
                } receiveValue: { [weak self] users in
                    self?.phase = .success
                    self?.users = users
                    print(users)
                    
                }.store(in: &subscriptions)
            
        case let .presentView(destination):
            modalDestination = destination
            
        case .presentMyProfileView:
            modalDestination = .myProfile
            
        case let .presentOtherProfileView(userId):
            modalDestination = .otherProfile(userId)
            
        case .requestContacts:
            container.services.contactService.fetchContacts() // 연락처에서 친구들 불러오기
                .flatMap { users in
                    self.container.services.userService.addUserAfterContact(users: users) // 불러온 친구들 파이어베이스 데이터베이스에 넣기
                }
            // 이후에 로드하기
                .flatMap { _ in
                    self.container.services.userService.loadUsers(id: self.userId)
                }
                .sink { [weak self] completion in
                    if case .failure = completion {
                        self?.phase = .fail
                    }
                } receiveValue: { [weak self] users in
                    self?.phase = .success
                    self?.users = users
                }.store(in: &subscriptions)
        case let .goToChat(otherUser):
            // ChatRooms/myUserId/otherUserId 에 채팅방 저장하기
            container.services.chatRoomService.createChatRoomIfNeeded(myUserId: userId, otherUserId: otherUser.id, otherUserName: otherUser.name)
                .sink { completion in
                    
                } receiveValue: { [weak self] chatRoom in
                    guard let `self` = self else { return }
                    self.navigationRouter.push(to: .chat(chatRoomId: chatRoom.chatRoomId, myUserId: self.userId, otherUserId: otherUser.id))
                }.store(in: &subscriptions)
            return
        }
    }
}
