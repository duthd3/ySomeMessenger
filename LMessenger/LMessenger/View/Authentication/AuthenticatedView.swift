//
//  ContentView.swift
//  LMessenger
//
//  Created by juni on 12/28/24.
//

import SwiftUI

struct AuthenticatedView: View {
    @StateObject var authViewModel: AuthenticationViewModel
    var body: some View {
        
        VStack {
            switch authViewModel.authenticationState {
            case .unauthenticated: // 비인증 상태일 경우
                LoginIntroView()
                    .environmentObject(authViewModel)
            case .authenticated: // 인증 상태일 경우
                MainTabView()
                    .environmentObject(authViewModel)
            }
        }
        .onAppear {
            authViewModel.send(action: .checkAuthenticationState)

            
        }
        
    }
}

#Preview {
    AuthenticatedView(authViewModel: .init(container: .init(services: StubService())))
}
