//
//  NavigationRouter.swift
//  LMessenger
//
//  Created by juni on 3/16/25.
//

import Foundation

class NavigationRouter: ObservableObject {
    
    @Published var destinations: [NavigationDestination] = []
    
    func push(to view: NavigationDestination) {
        destinations.append(view)
    }
    
    func pop() {
        _ = destinations.popLast()
    }
    
    func popToRootView() {
        destinations = []
    }
}
