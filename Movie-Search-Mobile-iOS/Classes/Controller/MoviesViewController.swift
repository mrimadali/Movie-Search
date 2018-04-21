//
//  ViewController.swift
//  Movie-Search-Mobile-iOS
//
//  Created by Imad on 4/17/18.
//  Copyright © 2018 Imad. All rights reserved.
//

import UIKit
import QuartzCore
import MBProgressHUD
import Reachability
import SwiftyJSON

class MoviesViewController: UIViewController {
    
    // MARK: - Class private variables
    
    // To check if internet connection is available.
    fileprivate let reachability        = Reachability()!
    fileprivate let tableViewIdentifier = "moviesCell"
    fileprivate let titleString         = "Movies"
    fileprivate var totalMoviesCount    = 0
    fileprivate var pageNumber          = 1
    fileprivate var totalPages          = 0
    fileprivate var moviesList          = [MovieModel]()
    fileprivate var isLoading           = false
    fileprivate var loadingActivity: UIActivityIndicatorView?
    var queries = [Query]()
    let entityName  = "Query"
    let managedObjectContext = CoreDataHelper.managedObjectContext()

    // MARK: - IBOutlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet var queryView: UIView!
    @IBOutlet weak var queryTableView: UITableView!

    public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    // MARK: - View life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchQueries()
    }

    // MARK: - Class private methods
    
    fileprivate func fetchMoviesList(keyword: String) {
        if keyword.count < 3  {
            MBProgressHUD.hide(for: self.view, animated: true)
            AppUtils.showAlert(title: titleString, mesg: alertTitle_Atleast_3_Characters, controller: self)
        }else{        
            let reachability = Reachability()!
            
            reachability.whenUnreachable = { _ in
                MBProgressHUD.hide(for: self.view, animated: true)
                AppUtils.showAlert(title: offlineText, mesg: offlineMessage, controller: self)
                return
            }
            reachability.whenReachable = { reachability in
                self.messageLabel.isHidden = true
                NetworkAdapter().getMoviesList(with: keyword, pageNumber: self.pageNumber) { (json, error) in
                    DispatchQueue.main.async {
                        self.parseMoviesData(keyword: keyword, error: error, json: json)
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

    fileprivate func parseMoviesData(keyword:String, error: Error?, json: JSON) {
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
                if !self.checkIfRecordExists(keyword: keyword) {
                    self.insertQuery(keyword: keyword)
                }
            }
            if self.queries.count > 10 {
                CoreDataHelper.deleteLastItem(className: entityName, managedObjectContext: managedObjectContext)
            }
            isLoading = false
            self.fetchQueries()
            self.tableView.reloadData()

            MBProgressHUD.hide(for: self.view, animated: true)
            loadingActivity?.stopAnimating()
        }else {
            MBProgressHUD.hide(for: self.view, animated: true)
            loadingActivity?.stopAnimating()
            AppUtils.showAlert(title: self.titleString, mesg: alertTitle_Server_Problem, controller: self)
        }
    }

    fileprivate func fetchQueries() {
        let queryArray = CoreDataHelper.fetchEntities(className: entityName, predicate: nil, sortDesc: nil, managedObjectContext: managedObjectContext) as! [Query]
        
        queries = queryArray.reversed()
    }
    
    fileprivate func insertQuery(keyword: String) {
        let query = CoreDataHelper.insertManagedObject(className: "Query", managedObjectContext: managedObjectContext) as! Query
        
        query.keyword  = keyword
        query.serialNo = Int16(queries.count.advanced(by: 1))
        CoreDataHelper.saveManagedObjectContext(managedObjectContext: managedObjectContext)
    }
    
    fileprivate func checkIfRecordExists(keyword: String)->Bool {
        var isExists = false
        let predicate = NSPredicate(format: "keyword == %@", keyword)
        let queryArray = CoreDataHelper.fetchEntities(className: entityName, predicate: predicate, sortDesc: nil, managedObjectContext: managedObjectContext) as! [Query]
        if queryArray.count > 0 {
            isExists = true
        }
        return isExists
    }
    
    fileprivate func getRecord(for keyword: String)->String {
        let predicate = NSPredicate(format: "keyword == %@", keyword)
        let queryArray = CoreDataHelper.fetchEntities(className: entityName, predicate: predicate, sortDesc: nil, managedObjectContext: managedObjectContext) as! [Query]
        if queryArray.count > 0 {
            return (queryArray.first?.keyword)!
        }
        return ""
    }
    
    fileprivate func showQueryView(show: Bool) {
        if show {
            queryView.frame = CGRect(x: 10, y: 56, width: Int(screenWidth-20), height: 35*self.queries.count)

            UIView.transition(with: view, duration: 0.5, options: .repeat, animations: {
                self.view.addSubview(self.queryView)

            }, completion: nil)
            
        }else {
            UIView.transition(with: view, duration: 0.5, options: .repeat, animations: {
                self.queryView.removeFromSuperview()
            }, completion: nil)

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

// MARK: - Table view datasource & delegate methods

extension MoviesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == queryTableView {
            return self.queries.count
        }else {
            if moviesList.count != totalMoviesCount {
                return moviesList.count+1
            }else {
                return moviesList.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        if tableView == queryTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "queryCell") as? QueryTableViewCell
            
            cell?.titleLabel?.text = queries[row].keyword
            
            return cell!
            
        }else {
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
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let row = indexPath.row
        if tableView != queryTableView {
            if row == moviesList.count && moviesList.count != totalMoviesCount && !isLoading {
                pageNumber += 1
                isLoading = true
                fetchMoviesList(keyword: searchBar.text!)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        if tableView == queryTableView {
            searchBar.resignFirstResponder()
            showQueryView(show: false)
            let keyword = getRecord(for: queries[row].keyword!)
            searchBar.text = keyword
            pageNumber          = 1
            self.moviesList.removeAll()
            MBProgressHUD.showAdded(to: self.view, animated: true)
            fetchMoviesList(keyword: searchBar.text!)

        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        if tableView == queryTableView {
            return 35.0
        }
        else if  row == moviesList.count {
            return 44.0
        }else {
            return 110.0
        }
    }
}

// MARK: - Search bar delegate methods

extension MoviesViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        queryTableView.reloadData()
        showQueryView(show: true)
        searchBar.showsCancelButton = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        showQueryView(show: false)
        searchBar.showsCancelButton = false
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        showQueryView(show: false)
        searchBar.showsCancelButton = false
        if (searchBar.text?.count)! > 0 {
            pageNumber          = 1
            self.moviesList.removeAll()
            MBProgressHUD.showAdded(to: self.view, animated: true)
            fetchMoviesList(keyword: searchBar.text!)
        }

    }
}

