//
//  AppearanceController.swift
//  LMessenger
//
//  Created by juni on 3/29/25.
//

import Foundation

class AppearanceController: ObservableObject {
    @Published var appearance: AppearenceType
    
    init(_ appearanceValue: Int) {
        self.appearance = AppearenceType(rawValue: appearanceValue) ?? .automatic
    }
    
    func changeAppearance(_ willBeAppearacne: AppearenceType) {
        appearance = willBeAppearacne
    }
}
