//
//  URLImageViewModel.swift
//  LMessenger
//
//  Created by juni on 3/16/25.
//

import UIKit
import Combine

class URLImageViewModel: ObservableObject {
    
    var loadingOrSuccess: Bool {
        return loading || loadedImage != nil
    }
    
    @Published var loadedImage: UIImage?
    
    private var loading: Bool = false
    private var urlString: String
    private var container: DIContainer
    private var subscriptions = Set<AnyCancellable>()
    
    init(container: DIContainer, urlString: String) {
        self.container = container
        self.urlString = urlString
    }
    
    func start() {
        guard !urlString.isEmpty else { return }
        
        loading = true
        
        container.services.imageCacheService.image(for: urlString)
            .subscribe(on: DispatchQueue.global()) // 백그라운드에서 작업
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.loading = false
                self?.loadedImage = image
            }.store(in: &subscriptions)
    }
}
