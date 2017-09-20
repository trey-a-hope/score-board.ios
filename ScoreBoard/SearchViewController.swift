import UIKit

class SearchViewController: UIViewController {
    let searchController = UISearchController(searchResultsController: nil)
    var searchButton: UIBarButtonItem!
    var thisViewController: UIViewController{
        return (self.navigationController?.visibleViewController)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(ConnectionManager.isConnectedToInternet()){
            initUI()
        }else{
            ModalService.showError(title: "Error", message: "No internet connection.")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reInitUI()
    }
    
    func initUI() -> Void {
        //Search Button
        searchButton = UIBarButtonItem(
            barButtonSystemItem: .search,
            target: self,
            action: #selector(SearchViewController.showSearchBar(_:))
        )
        
        //Configure searchbar.
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.showsCancelButton = true
        searchController.searchBar.placeholder = "Search"
        searchController.hidesNavigationBarDuringPresentation = false;
    }
    
    func reInitUI() -> Void {
        thisViewController.title = "Search"
        searchButton.isEnabled = ConnectionManager.isConnectedToInternet()
        thisViewController.navigationItem.setRightBarButtonItems([searchButton], animated: true)
    }
}

extension SearchViewController : UISearchResultsUpdating {
    
    func filterContentForSearchText(_ searchText: String, _ scope: String = "All") {
        //        filteredHighSchools = highSchools.filter { highSchool in
        //            return highSchool.name.lowercased().range(of: searchText.lowercased()) != nil
        //        }
        //        self.collectionView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        self.filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension SearchViewController : UISearchBarDelegate {
    /* Show search bar. */
    func showSearchBar(_ sender: UIBarButtonItem!) -> Void {
        searchController.searchBar.setShowsCancelButton(true, animated: true)
        thisViewController.navigationItem.setHidesBackButton(true, animated:true)
        thisViewController.navigationItem.titleView = searchController.searchBar
        thisViewController.navigationItem.rightBarButtonItems = nil
        thisViewController.navigationItem.leftBarButtonItems = nil
    }
    
    /* Hide search bar. */
    func hideSearchBar() -> Void {
        /* Add buttons to navbar. */
        thisViewController.navigationItem.setRightBarButtonItems([searchButton], animated: true)
        thisViewController.navigationItem.titleView = nil
        searchController.searchBar.text = ""
        searchController.searchBar.endEditing(true)
    }
    
    /* Cancel button function. */
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.hideSearchBar()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.filterContentForSearchText(searchBar.text!)
    }
}


