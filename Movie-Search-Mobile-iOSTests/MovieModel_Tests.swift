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
    
    let sut = MovieModel()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testMovieTitle() {
        sut.movieTitle = "Batman"
        XCTAssertEqual(sut.movieTitle, "Batman")
    }
    
    func testReleaseDate() {
        sut.releaseDate = "12-12-2017"
        XCTAssertEqual(sut.releaseDate, "12-12-2017")
    }
    func testPosterPath() {
        sut.posterPath = "http://posterpath"
        XCTAssertEqual(sut.posterPath, "http://posterpath")
    }
    
    func testOverview() {
        sut.overview = "Lorem ipsum dollar sit"
        XCTAssertEqual(sut.overview, "Lorem ipsum dollar sit")
    }
    
}
