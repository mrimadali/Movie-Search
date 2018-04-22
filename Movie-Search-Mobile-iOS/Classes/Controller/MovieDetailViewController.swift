//
//  MovieDetailViewController.swift
//  Movie-Search-Mobile-iOS
//
//  Created by Imad on 4/19/18.
//  Copyright © 2018 Imad. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    // MARK: - Class private variables
    
    let detailTableViewIdentifier = "movieDetailCell"
    var model: MovieModel?
    
    // MARK: - IBOutlets
     
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - View life cycle methods.
    // Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = model?.movieTitle
        
        tableView.estimatedRowHeight = 800
        tableView.rowHeight = UITableViewAutomaticDimension
    }
}

extension MovieDetailViewController: UITableViewDataSource, UITableViewDelegate {
    // Tells the data source to return the number of rows in a given section of a table view.
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Asks the data source for a cell to insert in a particular location of the table view.

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: detailTableViewIdentifier) as? MovieTableViewCell
        cell?.isDetailCell = true
        cell?.configureCell(model: self.model!)
        return cell!
    }
    
}



