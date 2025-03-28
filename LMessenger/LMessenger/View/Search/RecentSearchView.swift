//
//  RecentSearchView.swift
//  LMessenger
//
//  Created by juni on 3/29/25.
//

import SwiftUI

struct RecentSearchView: View {
    @Environment(\.managedObjectContext) var objectContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date)]) var results: FetchedResults<SearchResult> // SearchResult를 coredata 엔티티에서 가져오고 date순으로 정렬(ㄱㄷㅁㅇ)
    var body: some View {
        VStack(spacing: 0) {
            titleView
                .padding(.bottom, 20)
            
            if results.isEmpty {
                Text("검색 내역이 없습니다.")
                    .font(.system(size: 10))
                    .foregroundStyle(.greyDeep)
                    .padding(.vertical, 54)
                Spacer()
            } else {
                ScrollView {
                    LazyVStack {
                        ForEach(results, id: \.self) { result in
                            HStack {
                                Text(result.name ?? "")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.bkText)
                                Spacer()
                                Button {
                                    // data 삭제
                                    objectContext.delete(result) // 컨텍스트 내에서 삭제
                                    try? objectContext.save() // 영구 저장소에서 삭제 
                                } label: {
                                    Image("close_search")
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 30)
    }
    
    var titleView: some View {
        HStack {
            Text("최근 검색어")
                .font(.system(size: 18, weight: .bold))
            Spacer()
        }
     }
}

#Preview {
    RecentSearchView()
}
