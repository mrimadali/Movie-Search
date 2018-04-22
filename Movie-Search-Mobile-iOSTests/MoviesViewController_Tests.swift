//
//  MoviesViewController_Tests.swift
//  Movie-Search-Mobile-iOSTests
//
//  Created by Imad on 4/22/18.
//  Copyright © 2018 Imad. All rights reserved.
//

import XCTest
@testable import Movie_Search_Mobile_iOS

class MoviesViewController_Tests: XCTestCase {
    
    var sut: MoviesViewController?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        sut = storyboard.instantiateViewController(withIdentifier: "MoviesViewController") as? MoviesViewController
        _ = sut?.view
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
        
    func testNavigationTitle() {
        sut?.navigationItem.title = "Movies"
        XCTAssertEqual(sut?.navigationItem.title, "Movies")
    }
    
    func testMoviesCount() {
        XCTAssertEqual(sut?.totalMoviesCount, 0)
    }
    func testPageNumber() {
        XCTAssertEqual(sut?.pageNumber, 1)
    }
    
    func testTotalPages() {
        XCTAssertEqual(sut?.totalPages, 0)
    }
   
    func testIsLoading() {
        XCTAssertFalse((sut?.isLoading)!)
    }
    
    func testSearchBarNotNil() {
        XCTAssertNotNil(sut?.searchBar)
    }
    
    func testTableViewNotNil() {
        XCTAssertNotNil(sut?.tableView)
    }
    
    func testMessageLabelNotNil() {
        XCTAssertNotNil(sut?.messageLabel)
    }

    func testQueryViewNotNil() {
        XCTAssertNotNil(sut?.queryView)
    }
    
    func testQueryTableViewNotNil() {
        XCTAssertNotNil(sut?.queryTableView)
    }

    
}
