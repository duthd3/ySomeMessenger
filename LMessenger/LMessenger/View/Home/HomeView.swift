//
//  HomeView.swift
//  LMessenger
//
//  Created by juni on 2/9/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var container: DIContainer
    @EnvironmentObject var navigationRouter: NavigationRouter
    @StateObject var viewModel: HomeViewModel
    
    var body: some View {
        NavigationStack(path: $navigationRouter.destinations) {
           contentView
                .fullScreenCover(item: $viewModel.modalDestination) {
                    switch $0 {
                    case .myProfile:
                        MyProfileView(viewModel: .init(container: container, userId: viewModel.userId))
                    case let .otherProfile(userId):
                        OtherProfileView(viewModel: .init(container: container, userId: userId)) { otherUserInfo in
                            viewModel.send(action: .goToChat(otherUserInfo))
                        }
                    }
                }
                .navigationDestination(for: NavigationDestination.self) {
                    NavigationRoutingView(destination: $0)
                }
        }
    }
    
    @ViewBuilder
    var contentView: some View {
        switch viewModel.phase {
        case .notRequested:
            PlaceholderView()
                .onAppear {
                    viewModel.send(action: .load)

                }
        case .loading:
            LoadingView()
        case .success:
            loadedView
                .toolbar {
                    Image("bookmark")
                    Image("notifications")
                    Image("person_add")
                    Button {
                        // TODO: settings
                        
                    } label: {
                        Image("settings")
                    }
                }
        case .fail:
            ErrorView()
        }
    }
    
    var loadedView: some View {
        ScrollView {
            profileView
                .padding(.bottom, 30)
            NavigationLink(value: NavigationDestination.search(userId: viewModel.userId)) {
                SearchButton()
            }
            .padding(.bottom, 24)
            HStack {
                Text("친구")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.bkText)
                Spacer()
            }
            .padding(.horizontal, 30)
            
            // TODO: - 친구 목록
            // 친구가 없을 때
            if viewModel.users.isEmpty {
                emptyView
            } else {
                LazyVStack {
                    // 친구가 있을 때(무한히 늘어 나야 함)
                    ForEach(viewModel.users.sorted { $0.name < $1.name}, id: \.id) { user in
                        Button(action: {
                            viewModel.send(action: .presentOtherProfileView(user.id))
                        }, label: {
                            HStack(spacing: 8) {
                                Image("person")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                Text("\(user.name)")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.bkText)
                                Spacer()
                            }
                            .padding(.horizontal, 30)
                        })
                    }

                }
            }
        }
    }
    
    var profileView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 7) {
                Text(viewModel.myUser?.name ?? "이름")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.bkText)
                Text(viewModel.myUser?.description ?? "상태 메시지 입력")
                    .font(.system(size: 12))
                    .foregroundStyle(.greyDeep)
            }
            
            Spacer()
            
            Image("person")
                .resizable()
                .frame(width: 52, height: 52)
                .clipShape(Circle())
        }
        .padding(.horizontal, 30)
        .onTapGesture {
            viewModel.send(action: .presentMyProfileView)
        }
    }
    
    var searchButtonView: some View {
        NavigationLink(value: NavigationDestination.search(userId: viewModel.userId)) {
            SearchButton()
        }
    }
    
    var emptyView: some View {
        VStack {
            VStack(spacing: 3) {
                Text("친구를 추가해보세요.")
                    .foregroundStyle(Color.bkText)
                Text("QR code 나 검색을 이용해서 친구를 추가해보세요.")
                    .foregroundStyle(Color.greyDeep)
            }
            .font(.system(size: 14))
            .padding(.bottom, 30)
            
            Button {
                viewModel.send(action: .requestContacts)
            } label: {
                Text("친구 추가")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.bkText)
                    .padding(.vertical, 9)
                    .padding(.horizontal, 24)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(.greyLight)
            }
            
        }
    }
}

//#Preview {
//    let navigationRouter: NavigationRouter = .init()
//    HomeView(viewModel: .init(container: .init(services: StubService()), navigationRouter: navigationRouter, userId: "user1_id"))
//        .environmentObject(NavigationRouter())
//}
