//
//  SettingViewModel.swift
//  LMessenger
//
//  Created by juni on 3/29/25.
//

import Foundation

class SettingViewModel: ObservableObject {

    @Published var sectionItems: [SectionItem] = []
    
    init() {
        self.sectionItems = [
            .init(label: "모드설정", settings: AppearenceType.allCases.map { .init(item: $0) })
        ]
    }
}
