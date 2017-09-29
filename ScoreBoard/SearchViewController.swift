import UIKit

class SearchViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    let searchBar: UISearchBar = UISearchBar()
    
    //Navbar buttons
    var searchButton: UIBarButtonItem!
    
    //All search categories
    var athletes: [User] = [User]()
    var filteredAthletes: [User] = [User]()
    var highSchoolCoaches: [User] = [User]()
    var filteredHighSchoolCoaches: [User] = [User]()
    var collegeCoaches: [User] = [User]()
    var filteredCollegeCoaches: [User] = [User]()
    
    var categories: [String] = ["Active Games", "Users", "Teams"]
    
    var thisVC: UIViewController{
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
        searchBar.showsCancelButton = true
        searchBar.placeholder = "Search"
        searchBar.delegate = self
    }
    
    func reInitUI() -> Void {
        thisVC.title = "Search"
        searchButton.isEnabled = ConnectionManager.isConnectedToInternet()
        thisVC.navigationItem.setLeftBarButtonItems([], animated: true)
        thisVC.navigationItem.setRightBarButtonItems([searchButton], animated: true)
    }
}

extension SearchViewController : UISearchBarDelegate {
    //Show search bar
    func showSearchBar(_ sender: UIBarButtonItem!) -> Void {
        thisVC.navigationItem.setHidesBackButton(true, animated:true)
        thisVC.navigationItem.titleView = searchBar
        thisVC.navigationItem.rightBarButtonItems = nil
        thisVC.navigationItem.leftBarButtonItems = nil
    }
    
    //Hide search bar
    func hideSearchBar() -> Void {
        //Add buttons to navbar
        thisVC.navigationItem.setLeftBarButtonItems([], animated: true)
        thisVC.navigationItem.setRightBarButtonItems([searchButton], animated: true)
        thisVC.navigationItem.titleView = nil
        searchBar.text = ""
        searchBar.endEditing(true)
    }
    
    //Cancel button function
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.hideSearchBar()
    }
    
    //Text on change function for searchbar.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) -> Void {
        self.filterContentForSearchText(searchText)
    }
    
    //Filter data in tableview.
    func filterContentForSearchText(_ searchText: String) -> Void {
        //TODO:
    }
}


