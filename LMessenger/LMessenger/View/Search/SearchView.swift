//
//  SearchView.swift
//  LMessenger
//
//  Created by juni on 3/16/25.
//

import SwiftUI

struct SearchView: View {
    @Environment(\.managedObjectContext) var objectContext // 컨텍스트 가져오기(데이터 저장, 삭제, 업데이트 위해서)
    @EnvironmentObject var navigationRouter: NavigationRouter
    @StateObject var viewModel: SearchViewModel
    var body: some View {
        VStack {
            topView
            if viewModel.searchResults.isEmpty {
                RecentSearchView()
            } else {
                List {
                    ForEach(viewModel.searchResults) { result in
                        HStack(spacing: 8) {
                            URLImageView(urlString: result.profileURL)
                                .frame(width: 26, height: 26)
                                .clipShape(Circle())
                            Text(result.name)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.bkText)
                        }
                        .listRowInsets(.init())
                        .listRowSeparator(.hidden)
                        .padding(.horizontal, 30)
                    }
                }.listStyle(.plain)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }
    
    var topView: some View {
        HStack(spacing: 0) {
            Button(action: {
                navigationRouter.pop()
            }, label: {
                Image("back_search")
            })
            SearchBar(text: $viewModel.searchText, shouldBecomeFirstResponder: $viewModel.shouldBecomeFirstResponder) {
                // data 저장
                setSearchResultWithContext()
            }
            
            Button {
                viewModel.send(action: .clearSearchText)
            } label: {
                Image("close_search")
            }
        }
        .padding(.horizontal, 20)
    }
    
    func setSearchResultWithContext() { // 최근 검색어 data 저장
        let result = SearchResult(context: objectContext)
        result.id = UUID().uuidString
        result.name = viewModel.searchText
        result.date = Date()
        
        try? objectContext.save()
    }
}

#Preview {
    SearchView(viewModel: .init(container: DIContainer(services: StubService()), userId: "user1_id"))
}
