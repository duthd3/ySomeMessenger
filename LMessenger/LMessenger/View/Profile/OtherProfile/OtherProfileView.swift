//
//  OtherProfileView.swift
//  LMessenger
//
//  Created by juni on 3/2/25.
//

import SwiftUI

struct OtherProfileView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: OtherProfileViewModel
    
    var goToChat: (User) -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("profile_bg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea(edges: .vertical)
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    URLImageView(urlString: viewModel.userInfo?.profileURL)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .padding(.bottom, 16)
                    Text(viewModel.userInfo?.name ?? "이름")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.bgWh)
                    
                    Spacer()
                    
                    menuView
                        .padding(.bottom, 58)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                      dismiss()
                    }, label: {
                        Image("close")
                    })
                }
            }
            .task {
                await viewModel.getUser()
            }
        }
    }
    
    var menuView: some View {
        HStack(alignment: .top, spacing: 50) {
            ForEach(OtherProfileMenuType.allCases, id: \.self) { menu in
                Button {
                    if menu == .chat, let userInfo = viewModel.userInfo {
                        dismiss()
                        print(userInfo)
                        goToChat(userInfo)
                    }
                } label: {
                    VStack(alignment: .center) {
                        Image(menu.imageName)
                            .resizable()
                            .frame(width: 50, height: 50)
                        Text(menu.description)
                            .font(.system(size: 10))
                            .foregroundStyle(.bgWh)
                    }
                }
            }
        }
    }
}

#Preview {
    OtherProfileView(viewModel: .init(container: DIContainer(services: StubService()), userId: "user2_id")) { _ in
        
    }
}
