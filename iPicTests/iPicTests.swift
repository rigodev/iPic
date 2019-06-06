//
//  iPicTests.swift
//  iPicTests
//
//  Created by rigo on 06/06/2019.
//  Copyright © 2019 dev. All rights reserved.
//

import XCTest
@testable import iPic

class iPicTests: XCTestCase {
    
    var fetchedPhotos: [Photo]!
    
    override func setUp() {
        fetchedPhotos = []
        super.setUp()
    }
    
    override func tearDown() {
        fetchedPhotos = nil
        super.tearDown()
    }
    
    // test searchPhotosForString method
    func test_SearchReults() {
        // given
        let promise = expectation(description: "Result fetchPhotos status: success")
        
        // when
        XCTAssertEqual(fetchedPhotos.count, 0, "fetchedPhotos should be empty before the searching data")
        FlickrRESTAPI.searchPhotosForString("Car") { result in
       
            switch result {
                
            case .failure(let error):
                print(error.localizedDescription)
                
            case .success(let photos):
                self.fetchedPhotos = photos
                promise.fulfill()
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
        
        // then
        XCTAssertEqual(fetchedPhotos.count, 60, "Didn't parse 60 photos")
    }
}
