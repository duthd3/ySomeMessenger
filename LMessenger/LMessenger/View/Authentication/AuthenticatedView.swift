//
//  ContentView.swift
//  LMessenger
//
//  Created by juni on 12/28/24.
//

import SwiftUI
import CoreData

struct AuthenticatedView: View {
    @StateObject var authViewModel: AuthenticationViewModel
    @StateObject var navigationRouter: NavigationRouter
    @StateObject var searchDataController: SearchDataController
    var body: some View {
        
        VStack {
            switch authViewModel.authenticationState {
            case .unauthenticated: // 비인증 상태일 경우
                LoginIntroView()
                    .environmentObject(authViewModel)
            case .authenticated: // 인증 상태일 경우
                MainTabView()
                    .environment(\.managedObjectContext, searchDataController.persistentContainer.viewContext) // CoreData를 View에서 사용하기 위해 environment 지정
                    .environmentObject(authViewModel)
                    .environmentObject(navigationRouter)
                    .onAppear {
                        authViewModel.send(action: .requestPushNotification)
                    }
            }
        }
        .onAppear {
            authViewModel.send(action: .checkAuthenticationState)

            
        }
        
    }
}

#Preview {
    AuthenticatedView(authViewModel: .init(container: .init(services: StubService())), navigationRouter: .init(), searchDataController: .init()                  )
}
