//
//  Photo.swift
//  iPic
//
//  Created by rigo on 06/06/2019.
//  Copyright © 2019 dev. All rights reserved.
//

class Photo: Decodable {
    
    let id : String
    let title: String
    let farm : Int
    let server : String
    let secret : String
    var loadImageTime: String?
}


// MARK: - Equatable
extension Photo: Equatable {
    static func ==(_ left: Photo, _ right: Photo) -> Bool {
        return left.id == right.id
    }
}
