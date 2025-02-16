//
//  MainTabView.swift
//  LMessenger
//
//  Created by juni on 1/1/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: MainTabViewType = .home
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(MainTabViewType.allCases, id: \.self) { tab in
                Group {
                    switch tab {
                    case .home:
                        HomeView(viewModel: .init())
                    case .chat:
                        ChatListView()
                    case .phone:
                        Color.blackFix
                    }
                }
                .tabItem {
                    Label(tab.title, image: tab.imageName(selected: selectedTab == tab))
                }
                .tag(tab)
            }
        }
        .tint(.bkText)
    }
    
    init() {
        UITabBar.appearance().unselectedItemTintColor = UIColor(Color.bkText)
    }
}

#Preview {
    MainTabView()
}
