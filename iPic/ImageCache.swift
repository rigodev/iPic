//
//  ImageCache.swift
//  iPic
//
//  Created by rigo on 06/06/2019.
//  Copyright © 2019 dev. All rights reserved.
//

import UIKit

class ImageCache {
    
    private static let sharedInstance = ImageCache()
    
    var cache = [String: UIImage]()
    
    static var shared: ImageCache {
        return sharedInstance
    }
    
    private init() {
        NotificationCenter.default.addObserver(forName: UIApplication.didReceiveMemoryWarningNotification, object: nil, queue: .main) { [weak self] notification in
            
            self?.cache.removeAll(keepingCapacity: false)
        }
    }
    
    func loadThumbnail(for photo: Photo, completion: @escaping FlickrRESTAPI.FetchImageCompletion) {
        if let image = ImageCache.shared.image(forKey: photo.id) {
            completion(Result.success(image))
        }
        else {
            FlickrRESTAPI.loadImage(for: photo, withSize: "m") { result in
                if case .success(let image) = result {
                    ImageCache.shared.set(image, forKey: photo.id)
                }
                completion(result)
            }
        }
    }
    
    func loadDetail(for photo: Photo, completion: @escaping FlickrRESTAPI.FetchImageCompletion) {
        if let image = ImageCache.shared.image(forKey: "\(photo.id)-detail") {
            completion(Result.success(image))
        }
        else {
            FlickrRESTAPI.loadImage(for: photo, withSize: "b") { result in
                if case .success(let image) = result {
                    ImageCache.shared.set(image, forKey: "\(photo.id)-detail")
                }
                completion(result)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Custom Accessors
extension ImageCache {
    
    func set(_ image: UIImage, forKey key: String) {
        cache[key] = image
    }
    
    func image(forKey key: String) -> UIImage? {
        return cache[key]
    }
}

