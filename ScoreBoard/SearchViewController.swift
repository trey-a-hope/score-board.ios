import UIKit

class SearchViewController: UIViewController {
    let searchBar: UISearchBar = UISearchBar()
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
        let frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        let titleView = UIView(frame: frame)
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.placeholder = "Search"
        searchBar.backgroundImage = UIImage()
        searchBar.frame = frame
        titleView.addSubview(searchBar)
    }
    
    func reInitUI() -> Void {
        thisViewController.title = "Search"
        searchButton.isEnabled = ConnectionManager.isConnectedToInternet()
        thisViewController.navigationItem.setRightBarButtonItems([searchButton], animated: true)
    }
}

extension SearchViewController : UISearchBarDelegate {
    //Show search bar
    func showSearchBar(_ sender: UIBarButtonItem!) -> Void {
        thisViewController.navigationItem.setHidesBackButton(true, animated:true)
        thisViewController.navigationItem.titleView = searchBar
        thisViewController.navigationItem.rightBarButtonItems = nil
        thisViewController.navigationItem.leftBarButtonItems = nil
    }
    
    //Hide search bar
    func hideSearchBar() -> Void {
        /* Add buttons to navbar. */
        thisViewController.navigationItem.setRightBarButtonItems([searchButton], animated: true)
        thisViewController.navigationItem.titleView = nil
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


