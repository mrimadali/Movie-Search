//
//  MovieDetailViewController_Tests.swift
//  Movie-Search-Mobile-iOSTests
//
//  Created by Imad on 4/22/18.
//  Copyright © 2018 Imad. All rights reserved.
//

import XCTest
@testable import Movie_Search_Mobile_iOS

class MovieDetailViewController_Tests: XCTestCase {
    
    var sut: MovieDetailViewController?

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        sut = storyboard.instantiateViewController(withIdentifier: "MovieDetailViewController") as? MovieDetailViewController
        _ = sut?.view

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNavigationTitle() {
        sut?.navigationItem.title = "Batman"
        XCTAssertEqual(sut?.navigationItem.title, "Batman")
    }

    func testTableViewNotNil() {
        XCTAssertNotNil(sut?.tableView)
    }

    
    
}
