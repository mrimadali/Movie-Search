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

class MoviesViewController: UIViewController {
    fileprivate let reachability        = Reachability()!
    fileprivate let tableViewIdentifier = "moviesCell"
    fileprivate let titleString         = "Movies"
    fileprivate var pageNumber          = 1
    fileprivate var totalPages          = 0
    fileprivate var moviesList          = [MovieModel]()
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tableView.estimatedRowHeight = 150
//        tableView.rowHeight = UITableViewAutomaticDimension
        
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
                AppUtils.showAlert(title: "Offline", mesg: "You're internet connection appears to be offline", controller: self)
            }
            reachability.whenReachable = { reachability in
                MBProgressHUD.showAdded(to: self.view, animated: true)
                NetworkAdapter().getMoviesList(with: keyword, pageNumber: self.pageNumber) { (json, error) in
                    DispatchQueue.main.async {
                        if error == nil {
                            self.moviesList.removeAll()
                            self.totalPages = Int(json["total_pages"].stringValue)!
                            let results = json["results"].arrayValue
                            for movie in results {
                                let model = MovieModel()
                                model.copyFromDO(json: movie)
                                self.moviesList.append(model)
                            }
                            self.tableView.reloadData()
                            MBProgressHUD.hide(for: self.view, animated: true)
                            
                        }else {
                            MBProgressHUD.hide(for: self.view, animated: true)
                            AppUtils.showAlert(title: self.titleString, mesg: alertTitle_Server_Problem, controller: self)
                        }
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
        return moviesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: tableViewIdentifier) as? MovieTableViewCell
        let model = moviesList[row]
        cell?.configureCell(model: model)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
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
            fetchMoviesList(keyword: searchBar.text!)
        }

    }
}

