//
//  MainTabViewType.swift
//  LMessenger
//
//  Created by juni on 2/9/25.
//

import Foundation

enum MainTabViewType: String, CaseIterable {
    case home
    case chat
    case phone
    
    var title: String {
        switch self {
        case .home:
            return "홈"
        case .chat:
            return "대화"
        case .phone:
            return "통화"
        }
    }
    
    func imageName(selected: Bool) -> String {
        selected ? "\(rawValue)_fill" : rawValue
        
    }
}
