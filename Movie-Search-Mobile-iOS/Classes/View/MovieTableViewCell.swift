//
//  MovieTableViewCell.swift
//  Movie-Search-Mobile-iOS
//
//  Created by Imad on 4/17/18.
//  Copyright © 2018 Imad. All rights reserved.
//

import UIKit
import SDWebImage

class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    var isDetailCell = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bgView.layer.cornerRadius  = 1.0
        bgView.layer.shadowColor   = UIColor.black.cgColor
        bgView.layer.shadowOpacity = 0.2
        bgView.layer.shadowRadius  = 1.0
        bgView.layer.shadowOffset  = CGSize(width: 1.0, height: 1.0)
    }
    
    func configureCell(model: MovieModel) {
        releaseDateLabel.text = "Release Date: \(model.releaseDate.formatDate())"
        
        //Download image asynchronously.
        var urlString = ""
        if isDetailCell {
            urlString = "\(largePosterImageBaseURL)\(model.posterPath)"
            detailLabel.text = "Movie Overview: \(model.overview)"
        }else {
            movieNameLabel.text = model.movieTitle
            urlString = "\(posterImageBaseURL)\(model.posterPath)"
            detailLabel.text = "\(model.overview)"
        }
        let url = URL(string: urlString)
        if let imageURL = url {
            iconImageView.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "placeholder"))
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension String {
    func formatDate()-> String{
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd-MM-yyyy"
        
        if let date = dateFormatterGet.date(from: self){
            return dateFormatterPrint.string(from: date)
        }
        else {
            print("There was an error decoding the string")
            return ""
        }
    }
}


