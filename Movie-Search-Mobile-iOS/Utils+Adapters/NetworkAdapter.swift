    //
//  NetworkAdapter.swift
//  Movie-Search-Mobile-iOS
//
//  Created by Imad on 4/17/18.
//  Copyright © 2018 Imad. All rights reserved.
//

import UIKit
import SwiftyJSON

let baseURL = "http://api.themoviedb.org/3/search/movie"
let apiKey = "2696829a81b1b5827d515ff121700838"
let posterImageBaseURL = "http://image.tmdb.org/t/p/w185"
let largePosterImageBaseURL = "http://image.tmdb.org/t/p/w500"

typealias Completion = (_ response: JSON, _ error: Error?) -> Void

class NetworkAdapter: NSObject {
    
    func getMoviesList(with query: String, pageNumber:Int, completionBlock:@escaping Completion) {
        let urlString = "\(baseURL)?api_key=\(apiKey)&query=\(query)&page=\(pageNumber)"
        let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: encodedURL!)
        let config = URLSessionConfiguration.default
        
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: url!) { (data, response, error) in
            guard error == nil else {
                completionBlock(JSON.null,error)
                return
            }
            do {
                let jsonData = try JSON(data: data!)
                completionBlock(jsonData, nil)
            }catch {
                completionBlock(JSON.null,error)
            }
            
        }
    
        task.resume()
    }
}
