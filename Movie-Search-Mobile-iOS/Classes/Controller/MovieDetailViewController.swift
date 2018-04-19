//
//  MovieDetailViewController.swift
//  Movie-Search-Mobile-iOS
//
//  Created by Imad on 4/19/18.
//  Copyright © 2018 Imad. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let detailTableViewIdentifier = "movieDetailCell"
    
    var model: MovieModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = model?.movieTitle
        
        tableView.estimatedRowHeight = 800
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MovieDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: detailTableViewIdentifier) as? MovieTableViewCell
        cell?.isDetailCell = true
        cell?.configureCell(model: self.model!)
        return cell!
    }
    
}



