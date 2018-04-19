//
//  MovieModel.swift
//  Movie-Search-Mobile-iOS
//
//  Created by Imad on 4/18/18.
//  Copyright © 2018 Imad. All rights reserved.
//

import UIKit
import SwiftyJSON

class MovieModel: NSObject {
    var movieTitle  = ""
    var releaseDate = ""
    var posterPath  = ""
    var overview    = ""
    
    func copyFromDO(json:JSON) {
        movieTitle  = json["title"].stringValue
        releaseDate = json["release_date"].stringValue
        posterPath  = json["poster_path"].stringValue
        overview    = json["overview"].stringValue
    }
}
