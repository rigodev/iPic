//
//  FlickrRESTAPI.swift
//  iPic
//
//  Created by rigo on 06/06/2019.
//  Copyright © 2019 dev. All rights reserved.
//

import UIKit

enum Result<T> {
    case success(T)
    case failure(Error)
}

class FlickrRESTAPI {
    
    private static let apiKey = "5d948e182c58bb208f71132d9e186d47"
    
    private static var session: URLSession = {
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 10.0
        
        return URLSession(configuration: sessionConfig)
    }()
    
    private static var dataTask: URLSessionDataTask?
}

// MARK: - Searching data
extension FlickrRESTAPI {
    
    typealias FetchPhotosResult = Result<[Photo]>
    typealias FetchPhotosCompletion = (FetchPhotosResult) -> Void
    
    static func searchPhotosForString(_ searchString: String, completion: @escaping FetchPhotosCompletion) {
        
        guard let searchURL = searchURLForSearchString(searchString) else {
            return
        }
        
        dataTask?.cancel()
        
        let request = URLRequest(url: searchURL)
        
        dataTask = session.dataTask(with: request) { data, response, error in
            
            defer { self.dataTask = nil }
            
            let result = processSearchPhotosResponse(data: data, error: error)
            
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        dataTask?.resume()
    }
    
    private static func processSearchPhotosResponse(data: Data?, error: Swift.Error?) -> Result<[Photo]> {
        
        if let error = error {
            return .failure(error)
        }
        
        guard let data = data else {
            return .failure(Error.noData)
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let results = json as? [String:Any] else {
                return .failure(Error.jsonSerializationFailed(reason: "Failed to convert data to JSON"))
        }
        
        guard let apiResponse = results["stat"] as? String else {
            return .failure(Error.requestFailed(reason: "No status info in JSON response"))
        }
        
        let message = (results["message"] as? String) ?? ""
        
        switch apiResponse {
        case "ok":
            print("Results processed OK.\n" + message)
        case "fail":
            return .failure(Error.requestFailed(reason: "Request failed.\n" + message))
        default:
            return .failure(Error.requestFailed(reason: "Unknown API response.\n" + message))
        }
        
        guard let photosContainer = results["photos"] as? [String:Any],
            let photosReceived = photosContainer["photo"] as? [[String:Any]],
            let photosData = jsonToString(photosReceived)?.data(using: .utf8),
            let photos = try? JSONDecoder().decode([Photo].self, from: photosData) else {
                return .failure(Error.processingPhotosFailed(reason: "Could not get photos from JSON payload"))
        }
        
        return .success(photos)
    }
    
    private static func jsonToString(_ json: Any) -> String? {
        
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
            let converted = String(data: data, encoding: .utf8) else {
                return nil
        }
        return converted
    }
    
    private static func searchURLForSearchString(_ searchString:String) -> URL? {
        
        if let escapedString = searchString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            let URLString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&text=\(escapedString)&per_page=60&format=json&nojsoncallback=1"
            return URL(string: URLString)
        }
        return nil
    }
}

// MARK: - Image Loading
extension FlickrRESTAPI {
    
    typealias FetchImageResult = Result<UIImage>
    typealias FetchImageCompletion = (FetchImageResult) -> Void
    
    static func imageURL(for photo: Photo, size:String = "m") -> URL {
        return URL(string: "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_\(size).jpg")!
    }
    
    private static func processImageRequest(_ data: Data?, _ error: Swift.Error?) -> FetchImageResult {
        
        guard let imageData = data,
            let image = UIImage(data: imageData) else {
                
                if let error = error, data == nil {
                    return .failure(error)
                }
                else {
                    return .failure(Error.imageCreationFailed)
                }
        }
        
        return Result.success(image)
    }
    
    static func loadImage(for photo: Photo, withSize size: String, _ completion: @escaping FetchImageCompletion) {
        
        let session = URLSession.shared
        
        let url = imageURL(for: photo, size: size)
        
        let dataTask = session.dataTask(with: url) { [weak photo] data, response, error in
            let result = self.processImageRequest(data, error)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
            photo?.loadImageTime = dateFormatter.string(from: Date())
            
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        dataTask.resume()
    }
}

// MARK: - Error Definitions
extension FlickrRESTAPI {
    
    enum Error: Swift.Error {
        case noData
        case jsonSerializationFailed(reason: String)
        case requestFailed(reason: String)
        case processingPhotosFailed(reason: String)
        case imageCreationFailed
    }
}

extension FlickrRESTAPI.Error: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .noData:
            return "No data returned with response"
        case .jsonSerializationFailed(let reason):
            return reason
        case .requestFailed(let reason):
            return reason
        case .processingPhotosFailed(let reason):
            return reason
        case .imageCreationFailed:
            return "Could not create image from returned data"
        }
    }
}
