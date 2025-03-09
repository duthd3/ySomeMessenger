//
//  MyProfileDescEditView.swift
//  LMessenger
//
//  Created by juni on 3/9/25.
//

import SwiftUI

struct MyProfileDescEditView: View {
    @Environment(\.dismiss) var dimiss
    @State var description: String
    
    var onCompleted: (String) -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("상태메시지를 입력해주세요", text: $description)
                    .multilineTextAlignment(.center)
            }
            .toolbar {
                Button("완료") {
                    onCompleted(description)
                    dimiss()
                }
            }
        }
    }
}

#Preview {
    MyProfileDescEditView(description: "") { _ in }
}
