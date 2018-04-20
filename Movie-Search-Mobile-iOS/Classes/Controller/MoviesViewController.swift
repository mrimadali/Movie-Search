//
//  ViewController.swift
//  Movie-Search-Mobile-iOS
//
//  Created by Imad on 4/17/18.
//  Copyright © 2018 Imad. All rights reserved.
//

import UIKit
import MBProgressHUD
import Reachability
import SwiftyJSON

class MoviesViewController: UIViewController {
    // MARK: - Class private variables
    fileprivate let reachability        = Reachability()!
    fileprivate let tableViewIdentifier = "moviesCell"
    fileprivate let titleString         = "Movies"
    fileprivate var totalMoviesCount    = 0
    fileprivate var pageNumber          = 1
    fileprivate var totalPages          = 0
    fileprivate var moviesList          = [MovieModel]()
    fileprivate var isLoading           = false
    fileprivate var loadingActivity: UIActivityIndicatorView?
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }

    
    fileprivate func fetchMoviesList(keyword: String) {
        if keyword.count < 3  {
            AppUtils.showAlert(title: titleString, mesg: alertTitle_Atleast_3_Characters, controller: self)
        }else{        
            let reachability = Reachability()!
            
            reachability.whenUnreachable = { _ in
                MBProgressHUD.hide(for: self.view, animated: true)
                AppUtils.showAlert(title: "Offline", mesg: "You're internet connection appears to be offline", controller: self)
                return
            }
            reachability.whenReachable = { reachability in
                self.messageLabel.isHidden = true
                NetworkAdapter().getMoviesList(with: keyword, pageNumber: self.pageNumber) { (json, error) in
                    DispatchQueue.main.async {
                        self.parseMoviesData(error: error, json: json)
                    }
                }
            }
            do {
                try reachability.startNotifier()
            } catch {
                print("Unable to start notifier")
            }
        }
    }

    fileprivate func parseMoviesData(error: Error?, json: JSON) {
        if error == nil {
            self.totalPages = Int(json["total_pages"].stringValue)!
            self.totalMoviesCount = Int(json["total_results"].stringValue)!
            let results = json["results"].arrayValue
            for movie in results {
                let model = MovieModel()
                model.copyFromDO(json: movie)
                self.moviesList.append(model)
            }
            if self.moviesList.count == 0 {
                self.messageLabel.isHidden = false
                self.tableView.isHidden = true
                self.messageLabel.text = "No Movies Found. Please try again."
            }else {
                self.messageLabel.isHidden = true
                self.tableView.isHidden = false
            }
            isLoading = false
            self.tableView.reloadData()
            MBProgressHUD.hide(for: self.view, animated: true)
            loadingActivity?.stopAnimating()
        }else {
            MBProgressHUD.hide(for: self.view, animated: true)
            loadingActivity?.stopAnimating()
            AppUtils.showAlert(title: self.titleString, mesg: alertTitle_Server_Problem, controller: self)
        }
    }

    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        let selectedRow = tableView.indexPathForSelectedRow?.row
        let movieDetailsVC = segue.destination as! MovieDetailViewController
        movieDetailsVC.model = moviesList[selectedRow!]
     }
    
}

extension MoviesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if moviesList.count != totalMoviesCount {
            return moviesList.count+1
        }else {
            return moviesList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        if row == moviesList.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell")
            loadingActivity = cell?.viewWithTag(100) as? UIActivityIndicatorView
            loadingActivity?.startAnimating()
            return cell!
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: tableViewIdentifier) as? MovieTableViewCell
        let model = moviesList[row]
        cell?.configureCell(model: model)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let row = indexPath.row
        if row == moviesList.count && moviesList.count != totalMoviesCount && !isLoading {
            pageNumber += 1
            isLoading = true
            fetchMoviesList(keyword: searchBar.text!)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        if row == moviesList.count {
            return 44.0
        }else {
            return 110.0
        }
    }
}

extension MoviesViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        if (searchBar.text?.count)! > 0 {
            pageNumber          = 1
            self.moviesList.removeAll()
            MBProgressHUD.showAdded(to: self.view, animated: true)
            fetchMoviesList(keyword: searchBar.text!)
        }

    }
}

