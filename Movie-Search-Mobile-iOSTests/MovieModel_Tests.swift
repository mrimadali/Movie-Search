//
//  MovieModel_Tests.swift
//  Movie-Search-Mobile-iOSTests
//
//  Created by Imad on 4/22/18.
//  Copyright © 2018 Imad. All rights reserved.
//

import XCTest
@testable import Movie_Search_Mobile_iOS

class MovieModel_Tests: XCTestCase {
    
    let model = MovieModel()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    
    func testMovieTitle() {
        model.movieTitle = "Batman"
        XCTAssertEqual(model.movieTitle, "Batman")
    }
    
    func testReleaseDate() {
        model.releaseDate = "12-12-2017"
        XCTAssertEqual(model.releaseDate, "12-12-2017")
    }
    func testPosterPath() {
        model.posterPath = "http://posterpath"
        XCTAssertEqual(model.posterPath, "http://posterpath")
    }
    
    func testOverview() {
        model.overview = "Lorem ipsum dollar sit"
        XCTAssertEqual(model.overview, "Lorem ipsum dollar sit")
    }
    
}
