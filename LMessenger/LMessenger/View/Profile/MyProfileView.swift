//
//  MyProfileView.swift
//  LMessenger
//
//  Created by juni on 3/2/25.
//

import SwiftUI

struct MyProfileView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: MyProfileViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("profile_bg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea(edges: .vertical)
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    profileView
                        .padding(.bottom, 16)
                    
                    nameView
                        .padding(.bottom, 26)
                    
                    descriptionView
                    
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
    
    var profileView: some View {
        Button(action: {
            
        }, label: {
            Image("person")
                .resizable()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
        })
    }
    
    var nameView: some View {
        Text(viewModel.userInfo?.name ?? "이름없음")
            .font(.system(size: 24, weight: .bold))
            .foregroundStyle(.bgWh)
    }
    
    var descriptionView: some View {
        Button {
            // TODO:
            viewModel.isPresentedDescEditView.toggle()
        } label: {
            Text(viewModel.userInfo?.description ?? "상태메시지를 입력해주세요.")
                .font(.system(size: 14))
                .foregroundStyle(.bgWh)
        }
        .sheet(isPresented: $viewModel.isPresentedDescEditView) {
            MyProfileDescEditView(description: viewModel.userInfo?.description ?? "") { desc in
                Task {
                    await viewModel.updateDescription(desc)
                }
            }
        }
    }
    
    var menuView: some View {
        HStack(alignment: .top, spacing: 27) {
            ForEach(MyProfileMenuType.allCases, id: \.self) { menu in
                Button {
                    
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
    MyProfileView(viewModel: .init(container: DIContainer(services: StubService()), userId: "user1_id"))
}
