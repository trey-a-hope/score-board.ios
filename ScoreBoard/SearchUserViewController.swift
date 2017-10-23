import UIKit

class SearchUserViewController : UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    //Navbar buttons
    var searchButton: UIBarButtonItem!
    
    var users: [User] = [User]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.visibleViewController?.navigationItem.titleView = nil
        navigationController?.visibleViewController?.navigationItem.title = "Search"
        navigationController?.visibleViewController?.navigationItem.setRightBarButtonItems([searchButton], animated: true)
        navigationController?.hidesBarsOnSwipe = true
    }
    
    override var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden ?? false
    }
    
    func initUI() -> Void {
        ModalService.showAlert(title: "Search Page Needs Work", message: "", vc: self)
        
        //Configure Table View
        tableView.register(UINib.init(nibName: "SearchItem", bundle: nil), forCellReuseIdentifier: "SearchItem")
        tableView.delegate = self
        tableView.dataSource = self
        
        //Search Button
        searchButton = UIBarButtonItem(
            barButtonSystemItem: .search,
            target: self,
            action: #selector(showSearchBar(_:))
        )
        
        //Configure searchbar
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.showsCancelButton = true
        searchController.searchBar.delegate = self
        
        automaticallyAdjustsScrollViewInsets = false
    }
}

extension SearchUserViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            //Fetch users
            MyFSRef.getUsersFromSearch(category: "userName", search: searchText, numberOfUsers: 25)
                .then{ users -> Void in
                    self.users = users
                    self.tableView.reloadData()
                }.always{}
        }else{
            self.users = []
        }
    }
}

extension SearchUserViewController : UISearchBarDelegate {
    //Show search bar.
    @objc func showSearchBar(_ sender: UIBarButtonItem!) -> Void {
        navigationController?.visibleViewController?.navigationItem.setHidesBackButton(true, animated:false)
        
        let searchBarContainer = SearchBarContainerView(customSearchBar: searchController.searchBar)
        searchBarContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        
        navigationController?.visibleViewController?.navigationItem.titleView = searchBarContainer
        
        //Make active on show.
        searchController.isActive = true
        
        //navigationController?.visibleViewController?.navigationItem.setLeftBarButtonItems([], animated: true)
        navigationController?.visibleViewController?.navigationItem.setRightBarButtonItems([], animated: true)
    }
    
    func hideSearchBar() -> Void {
        navigationController?.visibleViewController?.navigationItem.setHidesBackButton(false, animated:false)
        
        navigationController?.visibleViewController?.navigationItem.titleView = nil
        
        navigationController?.visibleViewController?.navigationItem.setRightBarButtonItems([searchButton], animated: false)
        
        searchController.isActive = false
        
        tableView.reloadData()
    }
    
    //Cancel button function.
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) -> Void {
        hideSearchBar()
    }
}

extension SearchUserViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) -> Void {
        let user: User = users[indexPath.row]
        ModalService.showAlert(title: user.userName, message: user.id, vc: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SearchItem", for: indexPath as IndexPath) as? SearchItem{
            
            let user: User = users[indexPath.row]

            cell.name.text = user.userName
            cell.profilePic.kf.setImage(with: URL(string: user.imageDownloadUrl))
            
            return cell
        }
        fatalError("Unable to Dequeue Reusable Supplementary View")
    }
}
