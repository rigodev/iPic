//
//  ImageDetailViewModel.swift
//  iPic
//
//  Created by rigo on 06/06/2019.
//  Copyright © 2019 dev. All rights reserved.
//

import UIKit

protocol ImageDetailViewModelProtocol: class {
    
    func fetchDetail(forPhoto photo: Photo, completion: @escaping FlickrRESTAPI.FetchImageCompletion)
}

class ImageDetailViewModel: ImageDetailViewModelProtocol {
    
    func fetchDetail(forPhoto photo: Photo, completion: @escaping FlickrRESTAPI.FetchImageCompletion) {
        
        ImageCache.shared.loadDetail(for: photo) { result in
            completion(result)
        }
    }
}
