import PromiseKit
import SafariServices
import UIKit

class Item {
    var id: String!
    var url: String!
    var group: String!
    var imageDownloadUrl: String!
    var name: String!
    var gameOwnerId: String!//ID if the user who owns the game for game items
}

//TODO: FIX SEARCH, ACTING WACKY RIGHT NOW
//TODO: REMOVE SEARCHBAR WHEN ACTIVE AND GOING TO NEW TAB
class SearchViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    //Navbar buttons
    var searchButton: UIBarButtonItem!
    
    //All search categories
    var games: [Item] = [Item]()            //MAY NOT NEED
    var filteredGames: [Item] = [Item]()
    var users: [Item] = [Item]()            //MAY NOT NEED
    var filteredUsers: [Item] = [Item]()
    var teams: [Item] = [Item]()            //MAY NOT NEED
    var filteredTeams: [Item] = [Item]()
    
    var categories: [String] = ["Taken Games", "Users", "Teams"]
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ModalService.showAlert(title: "Search Page Not Working", message: "Still needs work.", vc: self)
        
        navigationController?.visibleViewController?.navigationItem.titleView = nil
        navigationController?.visibleViewController?.navigationItem.title = "Search"
        navigationController?.visibleViewController?.navigationItem.setRightBarButtonItems([searchButton], animated: true)
        navigationController?.hidesBarsOnSwipe = true
    }
    
    override var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden ?? false
    }
    
    func initUI() -> Void {
        //Set teams
        for team in NBATeamService.instance.teams {
            let teamItem: Item = Item()
            teamItem.imageDownloadUrl = team.imageDownloadUrl
            teamItem.name = team.city + " " + team.name
            teamItem.group = self.categories[2]
            teamItem.url = team.url
            teams.append(teamItem)
        }
        
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

extension SearchViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            //Clear list on each text query.
            games.removeAll()
            users.removeAll()
            
            //Fetch games, users, and teams.
            when(fulfilled: MyFSRef.getGames(), MyFSRef.getUsersFromSearch(category: "userName", search: searchText, numberOfUsers: 25))
                .then{ (result) -> Void in
                    //Set games
                    for game in result.0 {
                        //Only return occupied games
                        if game.userId != nil {
                            let homeTeam: NBATeam = NBATeamService.instance.teams.filter{ $0.id == game.homeTeamId }.first!
                            let awayTeam: NBATeam = NBATeamService.instance.teams.filter{ $0.id == game.awayTeamId }.first!
                            
                            let gameItem: Item = Item()
                            gameItem.id = game.id
                            gameItem.imageDownloadUrl = homeTeam.imageDownloadUrl
                            gameItem.name = homeTeam.name + " vs. " + awayTeam.name
                            gameItem.group = self.categories[0]
                            gameItem.gameOwnerId = game.userId
                            self.games.append(gameItem)
                        }
                    }
                    //Sort game items
                    self.games = self.games.sorted(by: { $0.name < $1.name })
                    //Remove any duplicates
                    self.games = self.removeDuplicates(array: self.games)
                    //Filter on search
                    self.filteredGames = self.games.filter({
                        $0.name.range(of: searchText, options: .caseInsensitive) != nil
                    })
                    
                    //Set users
                    for user in result.1 {
                        let userItem: Item = Item()
                        userItem.id = user.id
                        userItem.imageDownloadUrl = user.imageDownloadUrl
                        userItem.name = user.userName
                        userItem.group = self.categories[1]
                        self.users.append(userItem)
                    }
                    //Sort users by name
                    self.users = self.users.sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
                    //Remove any duplicates
                    self.users = self.removeDuplicates(array: self.users)
                    //Filter on search
                    self.filteredUsers = self.users
                    
                    //Remove any duplicates
                    //Filter on search
                    self.filteredTeams = self.teams.filter({
                        $0.name.range(of: searchText, options: .caseInsensitive) != nil
                    })
                }.always{}
        } else {
            filteredGames.removeAll()
            filteredUsers.removeAll()
            filteredTeams.removeAll()
        }
        tableView.reloadData()
    }
}

extension SearchViewController : UISearchBarDelegate {
    //Show search bar.
    @objc func showSearchBar(_ sender: UIBarButtonItem!) -> Void {
        navigationController?.visibleViewController?.navigationItem.setHidesBackButton(true, animated:false)
        
        let searchBarContainer = SearchBarContainerView(customSearchBar: searchController.searchBar)
        searchBarContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        
        navigationController?.visibleViewController?.navigationItem.titleView = searchBarContainer
        
        //Make active on show.
        searchController.isActive = true
        
        navigationController?.visibleViewController?.navigationItem.setLeftBarButtonItems([], animated: true)
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
        self.hideSearchBar()
    }
    
    func removeDuplicates(array: [Item]) -> [Item] {
        var encountered = Set<String>()
        var result: [Item] = []
        for value in array {
            if encountered.contains(value.id) {
                // Do not add a duplicate element.
            }
            else {
                // Add value to the set.
                encountered.insert(value.id)
                // ... Append the value.
                result.append(value)
            }
        }
        return result
    }

}

extension SearchViewController : UITableViewDataSource, UITableViewDelegate {
    func getItemFromIndexPath(_ indexPath: IndexPath) -> Item {
        return itemsInCategory(indexPath.section)[indexPath.row]
    }
    
    func itemsInCategory(_ index: Int) -> [Item] {
        switch(index){
            case 0:
                return filteredGames
            case 1:
                return filteredUsers
            case 2:
                return filteredTeams
            default:
                return []
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categories[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section){
            case 0:
                return filteredGames.count
            case 1:
                return filteredUsers.count
            case 2:
                return filteredTeams.count
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) -> Void {
        let item: Item = getItemFromIndexPath(indexPath)
        
        switch(indexPath.section){
            //Games
            case 0:
                let fullGameViewController = storyBoard.instantiateViewController(withIdentifier: "FullGameViewController") as! FullGameViewController
                fullGameViewController.gameId = item.id
                self.navigationController?.pushViewController(fullGameViewController, animated: true)
                break
            //Users
            case 1:
                let profileViewController = storyBoard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                profileViewController.userId = item.id
                self.navigationController?.pushViewController(profileViewController, animated: true)
                break
            //Teams
            case 2:
                let svc = SFSafariViewController(url: NSURL(string: item.url)! as URL)
                svc.delegate = self
                svc.preferredBarTintColor = Constants.primaryColor
                svc.preferredControlTintColor = .white
                svc.modalPresentationStyle = .formSheet
                svc.modalTransitionStyle = .crossDissolve
                present(svc, animated: true, completion: nil)
                break
            default:break
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SearchItem", for: indexPath as IndexPath) as? SearchItem{
            
            let item: Item = getItemFromIndexPath(indexPath)
            
            cell.name.text = item.name
            cell.profilePic.kf.setImage(with: URL(string: item.imageDownloadUrl))
            
            return cell
        }
        fatalError("Unable to Dequeue Reusable Supplementary View")
    }
    
    //Hides sections until text is entered in search bar
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if searchController.isActive{
            return 30.0
        }else{
            return 0.0
        }
    }
}

extension SearchViewController : SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) -> Void {
        controller.dismiss(animated: true, completion: nil)
    }
}
