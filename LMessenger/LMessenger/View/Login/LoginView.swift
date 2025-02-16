//
//  LoginView.swift
//  LMessenger
//
//  Created by juni on 1/1/25.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @Environment(\.dismiss) var dismiss // 뷰 dismiss
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Group {
                Text("로그인")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.bkText)
                    .padding(.top, 80)
                Text("아래 제공되는 서비스로 로그인을 해주세요.")
                    .font(.system(size: 14))
                    .foregroundStyle(.greyDeep)
            }
            .padding(.horizontal, 30)
            
            
            Spacer()
            
            Button(action: {
                // TODO: Google Login
                authViewModel.send(action: .googleLogin)
            }, label: {
                Text("Google로 로그인")
                    .font(.system(size: 14))
            }).buttonStyle(LoginButtonStyle(textColor: .bkText, borderColor: .greyLight))
            
            SignInWithAppleButton { request in
                // TODO:
                authViewModel.send(action: .appleLogin(request))
            } onCompletion: { result in
                // TODO: 
                authViewModel.send(action: .appleLoginCompletion(result))
            }
            .frame(height: 40)
            .padding(.horizontal, 15)
            .cornerRadius(5)

            
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image("back")
                }

            }
        }
        .overlay {
            if authViewModel.isLoading {
                ProgressView()
            }
        }
    }
}

#Preview {
    LoginView()
}
