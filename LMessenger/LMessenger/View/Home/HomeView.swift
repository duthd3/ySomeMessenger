//
//  HomeView.swift
//  LMessenger
//
//  Created by juni on 2/9/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                profileView
                    .padding(.bottom, 30)
                searchButtonView
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
                    // 친구가 있을 때
                    ForEach(viewModel.users, id: \.id) { user in
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
                    }
                }
    
            }
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
            .onAppear {
                viewModel.send(action: .getUser)
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
    }
    
    var searchButtonView: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.clear)
                .frame(height: 36)
                .background(Color.greyCool)
                .cornerRadius(5)
            HStack {
                Text("검색")
                    .font(.system(size: 12))
                    .foregroundStyle(.greyLightVer2)
                Spacer()
            }
            .padding(.leading, 22)
        }
        .padding(.horizontal, 30)
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

#Preview {
    HomeView(viewModel: .init(container: .init(services: StubService()), userId: "user1_id"))
}
