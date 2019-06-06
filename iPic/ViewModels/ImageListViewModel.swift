//
//  ImageListViewModel.swift
//  iPic
//
//  Created by rigo on 06/06/2019.
//  Copyright © 2019 dev. All rights reserved.
//

import UIKit

protocol ImageListViewModelProtocol: class {
    
    func fetchPhotos(forString searchString: String, completion: @escaping FlickrRESTAPI.FetchPhotosCompletion)
    func fetchThumbnail(forPhoto photo: Photo, completion: @escaping FlickrRESTAPI.FetchImageCompletion)
}

class ImageListViewModel: ImageListViewModelProtocol {
    
    func fetchPhotos(forString searchString: String, completion: @escaping FlickrRESTAPI.FetchPhotosCompletion) {
        FlickrRESTAPI.searchPhotosForString(searchString) { result in
            completion(result)
        }
    }
    
    func fetchThumbnail(forPhoto photo: Photo, completion: @escaping FlickrRESTAPI.FetchImageCompletion) {
        
        ImageCache.shared.loadThumbnail(for: photo) { result in
            completion(result)
        }
    }
}
