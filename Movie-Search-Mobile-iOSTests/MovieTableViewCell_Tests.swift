//
//  MovieTableViewCell_Tests.swift
//  Movie-Search-Mobile-iOSTests
//
//  Created by Imad on 4/22/18.
//  Copyright © 2018 Imad. All rights reserved.
//

import XCTest
@testable import Movie_Search_Mobile_iOS

class MovieTableViewCell_Tests: XCTestCase {
    var sut: MovieTableViewCell?

    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        sut = MovieTableViewCell(style: .default, reuseIdentifier: "moviesCell")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
}
