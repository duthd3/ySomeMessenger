//
//  ChatImageItemView.swift
//  LMessenger
//
//  Created by juni on 3/23/25.
//

import SwiftUI

struct ChatImageItemView: View {
    let urlString: String
    let direction: ChatItemDirection
    let date: Date
    
    var body: some View {
        HStack(alignment: .bottom) {
            if direction == .right {
                Spacer()
                dateView
            }
            URLImageView(urlString: urlString)
                .frame(width: 146, height: 146)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            if direction == .left {
                dateView
                Spacer()
            }
        }
        .padding(.horizontal, 35)
    }
    var dateView: some View {
        
        Text(date.toChatTime)
            .font(.system(size: 10))
            .foregroundStyle(.greyDeep)
    }
}

#Preview {
    ChatImageItemView(urlString: "", direction: .right, date: Date())
}
