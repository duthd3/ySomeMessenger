//
//  HomeModalDestination.swift
//  LMessenger
//
//  Created by juni on 3/2/25.
//

import Foundation

enum HomeModalDestination: Hashable, Identifiable {
    case myProfile
    case otherProfile(String)
    case setting
    
    var id: Int {
        hashValue
    }
}
