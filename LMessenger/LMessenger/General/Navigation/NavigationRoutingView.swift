//
//  NavigationRoutingView.swift
//  LMessenger
//
//  Created by juni on 3/19/25.
//

import SwiftUI

struct NavigationRoutingView: View {
    @State var destination: NavigationDestination
    var body: some View {
        switch destination {
        case .chat:
            ChatView()
        case .search:
            SearchView()
        }
    }
}
