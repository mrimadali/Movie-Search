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
    // Movies table view identifier.
    fileprivate let tableViewIdentifier = "moviesCell"
    // Screen title.
    fileprivate let titleString         = "Movies"
    // Total movies count from a web service.
    var totalMoviesCount    = 0
    // Movies page number.
    var pageNumber          = 1
    // Total number of pages from a web service.
    var totalPages          = 0
    // List of the movies fetched from a web service
    fileprivate var moviesList          = [MovieModel]()
    // Is page is loading holds boolean value.
    var isLoading           = false
    // Loading activity indicator.
    fileprivate var loadingActivity: UIActivityIndicatorView?
    // Core data - Fetch total queries and store in the 'queries'
    var queries = [Query]()
    // Core data - Entity name.
    let entityName  = "Query"
    // Core data - An object representing a single object space or scratch pad that you use to fetch, create, and save managed objects.
    let managedObjectContext = CoreDataHelper.managedObjectContext()

    // MARK: - IBOutlets
    // Used to search the movies by entering the queries/keywords.
    @IBOutlet weak var searchBar: UISearchBar!
    // Used to display the movies results in a table.
    @IBOutlet weak var tableView: UITableView!
    // Used to display the proper message if table view is empty.
    @IBOutlet weak var messageLabel: UILabel!
    // Used to display the queries view if exists.
    @IBOutlet var queryView: UIView!
    // Used to display the list of queries in a table.
    @IBOutlet weak var queryTableView: UITableView!

    // Used to get the device screen width.
    public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    // Used to get the device screen Height.
    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    // MARK: - View life cycle methods
    //Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Fetches the queries from the Core data store.
        fetchQueries()
    }

    // MARK: - Class private methods
    // Fetches the movies from the web service.
    fileprivate func fetchMoviesList(keyword: String) {
        //Check If the the keyword count is less than 3 then show message to user.
        if keyword.count < 3  {
            MBProgressHUD.hide(for: self.view, animated: true)
            AppUtils.showAlert(title: titleString, mesg: alertTitle_Atleast_3_Characters, controller: self)
        }else{
            // Else, check if network is reachable using reachability
            let reachability = Reachability()!
            
            // When Unreachable, show alert message to user.
            reachability.whenUnreachable = { _ in
                MBProgressHUD.hide(for: self.view, animated: true)
                AppUtils.showAlert(title: offlineText, mesg: offlineMessage, controller: self)
                return
            }
            // When reachable, execute the web service to get the movie list based upon the keyword.
            reachability.whenReachable = { reachability in
                self.messageLabel.isHidden = true
                NetworkAdapter().getMoviesList(with: keyword, pageNumber: self.pageNumber) { (json, error) in
                    DispatchQueue.main.async {
                        // Parse the movies data.
                        self.parseMoviesData(keyword: keyword, error: error, json: json)
                    }
                }
            }
            
            // Start reachability notifier
            do {
                try reachability.startNotifier()
            } catch {
                print("Unable to start notifier")
            }
        }
    }

    // Parse the movies data by taking keyword, error and JSON response as params.
    fileprivate func parseMoviesData(keyword:String, error: Error?, json: JSON) {
        // Check if error exists.
        if error == nil {
            // Parse the data, use model & append it to the array list.
            self.totalPages = Int(json["total_pages"].stringValue)!
            self.totalMoviesCount = Int(json["total_results"].stringValue)!
            let results = json["results"].arrayValue
            // Iterate through the results (movies).
            for movie in results {
                let model = MovieModel()
                model.copyFromDO(json: movie)
                self.moviesList.append(model)
            }
            // Check if the movies count is zero.
            if self.moviesList.count == 0 {
                self.messageLabel.isHidden = false
                self.tableView.isHidden = true
                self.messageLabel.text = noResultsFound
            }else {
                self.messageLabel.isHidden = true
                self.tableView.isHidden = false
                if !self.checkIfRecordExists(keyword: keyword) {
                    // Core data - Insert query.
                    self.insertQuery(keyword: keyword)
                }
            }
            // Check if queries are more than 10 then delete the last entered query.
            if self.queries.count > 10 {
                CoreDataHelper.deleteLastItem(className: entityName, managedObjectContext: managedObjectContext)
            }
            // Reload the table view data.
            isLoading = false
            self.fetchQueries()
            self.tableView.reloadData()
            // Hide the acticity and MBProgressHUD.
            MBProgressHUD.hide(for: self.view, animated: true)
            loadingActivity?.stopAnimating()
        }else {
            // IF error exists, Show alert to the user.
            MBProgressHUD.hide(for: self.view, animated: true)
            loadingActivity?.stopAnimating()
            AppUtils.showAlert(title: self.titleString, mesg: alertTitle_Server_Problem, controller: self)
        }
    }

    // Core data - Fetch queries from Persistent store.
    fileprivate func fetchQueries() {
        let queryArray = CoreDataHelper.fetchEntities(className: entityName, predicate: nil, sortDesc: nil, managedObjectContext: managedObjectContext) as! [Query]
        
        queries = queryArray.reversed()
    }
    
    // Core data - Inser a query in Persistent store.
    fileprivate func insertQuery(keyword: String) {
        let query = CoreDataHelper.insertManagedObject(className: "Query", managedObjectContext: managedObjectContext) as! Query
        
        query.keyword  = keyword
        query.serialNo = Int16(queries.count.advanced(by: 1))
        CoreDataHelper.saveManagedObjectContext(managedObjectContext: managedObjectContext)
    }
    
    // Core data - Check if keyword exist in the Persistent store.
    fileprivate func checkIfRecordExists(keyword: String)->Bool {
        var isExists = false
        let predicate = NSPredicate(format: "keyword == %@", keyword)
        let queryArray = CoreDataHelper.fetchEntities(className: entityName, predicate: predicate, sortDesc: nil, managedObjectContext: managedObjectContext) as! [Query]
        if queryArray.count > 0 {
            isExists = true
        }
        return isExists
    }
    
    // Core data - Fetch record for a given keyword.
    fileprivate func getRecord(for keyword: String)->String {
        let predicate = NSPredicate(format: "keyword == %@", keyword)
        let queryArray = CoreDataHelper.fetchEntities(className: entityName, predicate: predicate, sortDesc: nil, managedObjectContext: managedObjectContext) as! [Query]
        if queryArray.count > 0 {
            return (queryArray.first?.keyword)!
        }
        return ""
    }
    
    // Show query list view, when user start editing the search bar (UISearchbar)
    fileprivate func showQueryView(show: Bool) {
        if show {
            // Animate the queries list view.
            queryView.frame = CGRect(x: 10, y: 56, width: Int(screenWidth-20), height: 35*self.queries.count)

            UIView.transition(with: view, duration: 0.5, options: .repeat, animations: {
                self.view.addSubview(self.queryView)

            }, completion: nil)
            
        }else {
            // Hide the queries list view
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
    
    // Tells the data source to return the number of rows in a given section of a table view.

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Check if the query table then return queries count otherwise movies count.
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
    
    // Asks the data source for a cell to insert in a particular location of the table view.

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        // Check if the query table.
        if tableView == queryTableView {
            // Returns a reusable table-view cell object located by its identifier.
            let cell = tableView.dequeueReusableCell(withIdentifier: "queryCell") as? QueryTableViewCell
            
            cell?.titleLabel?.text = queries[row].keyword
            
            return cell!
            
        }else {
            // Check if the the row is equal to movies list count then display loading cell.
            if row == moviesList.count {
                // Returns a reusable table-view cell object located by its identifier.
                let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell")
                loadingActivity = cell?.viewWithTag(100) as? UIActivityIndicatorView
                loadingActivity?.startAnimating()
                return cell!
            }
            // Otherwise use the movie table view cell.
            let cell = tableView.dequeueReusableCell(withIdentifier: tableViewIdentifier) as? MovieTableViewCell
            let model = moviesList[row]
            cell?.configureCell(model: model)
            return cell!
        }
    }
    
    // Tells the delegate the table view is about to draw a cell for a particular row.
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let row = indexPath.row
        // Check if the table view is not query table.
        if tableView != queryTableView {
            if row == moviesList.count && moviesList.count != totalMoviesCount && !isLoading {
                pageNumber += 1
                isLoading = true
                // Initiate the web service call.
                fetchMoviesList(keyword: searchBar.text!)
            }
        }
    }
    
    // Tells the delegate that the specified row is now selected.
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        // Check if the table view is query table.
        if tableView == queryTableView {
            // Resign the keyboard.
            searchBar.resignFirstResponder()
            // Hide the keyboard.
            showQueryView(show: false)
            // Get the keyword from the Persistant store.
            let keyword = getRecord(for: queries[row].keyword!)
            searchBar.text = keyword
            pageNumber          = 1
            // Remove all the movies from the list.
            self.moviesList.removeAll()
            MBProgressHUD.showAdded(to: self.view, animated: true)
            // Initiate the web service call.
            fetchMoviesList(keyword: searchBar.text!)

        }
    }
    
    // Asks the delegate for the height to use for a row in a specified location.

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        if tableView == queryTableView {
            return queryCellHeight
        }
        else if  row == moviesList.count {
            return defaultCellHeight
        }else {
            return movieCellHeight
        }
    }
}

// MARK: - Search bar delegate methods

extension MoviesViewController: UISearchBarDelegate {
    // Tells the delegate when the user begins editing the search text.

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // Reload the query table view data.
        queryTableView.reloadData()
        // Show query view to user.
        showQueryView(show: true)
        // A Boolean value indicating whether the cancel button is displayed.
        searchBar.showsCancelButton = true
    }
    
    // Tells the delegate that the cancel button was tapped.

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Resign the keyboard.
        searchBar.resignFirstResponder()
        // Hide query view to user.
        showQueryView(show: false)
        // A Boolean value indicating whether the cancel button is displayed.
        searchBar.showsCancelButton = false
    }
    
    // Tells the delegate that the search button was tapped.
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Resign the keyboard.
        searchBar.resignFirstResponder()
        // Hide query view to user.
        showQueryView(show: false)
        // Hide cancel button.
        searchBar.showsCancelButton = false
        // Check if the search bar text count is greater than zero.
        if (searchBar.text?.count)! > 0 {
            // Initiate the web service call.
            pageNumber          = 1
            self.moviesList.removeAll()
            MBProgressHUD.showAdded(to: self.view, animated: true)
            fetchMoviesList(keyword: searchBar.text!)
        }
    }
}

