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
    
    var movieVC: MoviesViewController?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        movieVC = storyboard.instantiateViewController(withIdentifier: "MoviesViewController") as? MoviesViewController
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testNavigationTitle() {
        movieVC?.navigationItem.title = "Movies"
        XCTAssertEqual(movieVC?.navigationItem.title, "Movies")
    }
    
    func testMoviesCount() {
        XCTAssertEqual(movieVC?.totalMoviesCount, 0)
    }
    func testPageNumber() {
        XCTAssertEqual(movieVC?.pageNumber, 1)
    }
    
    func testTotalPages() {
        XCTAssertEqual(movieVC?.totalPages, 0)
    }
   
    func testIsLoading() {
        XCTAssertFalse((movieVC?.isLoading)!)
    }
    
    func testSearchBar() {
        XCTAssertNil(movieVC?.searchBar)
    }
}
