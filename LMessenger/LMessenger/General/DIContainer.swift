//
//  DIContainer.swift
//  LMessenger
//
//  Created by juni on 1/1/25.
//

import Foundation

class DIContainer: ObservableObject {
 
    var services: ServiceType
    
    init(services: ServiceType) {
        self.services = services
    }
}
