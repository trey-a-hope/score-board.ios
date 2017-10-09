import PromiseKit
import SafariServices
import UIKit

//TODO: Prevent search bar text from disappearing on return from NBA Website

//Represent a search item's information
class Item {
    var id: String!
    var url: String!
    var group: String!
    var imageDownloadUrl: String!
    var name: String!
}

class SearchViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var searchBar: UISearchBar!
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    
    //All search categories
    var games: [Item] = [Item]()
    var filteredGames: [Item] = [Item]()
    var users: [Item] = [Item]()
    var filteredUsers: [Item] = [Item]()
    var teams: [Item] = [Item]()
    var filteredTeams: [Item] = [Item]()
    
    var categories: [String] = ["Games", "Users", "Teams"]
    
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
        
        //Configure searchbar.
        searchBar = UISearchBar()
        searchBar.placeholder = "Search, (case sensitive for users)"
        searchBar.delegate = self
        
        navigationController?.visibleViewController?.title = "Search"
        navigationController?.visibleViewController?.navigationItem.setRightBarButtonItems([], animated: true)
        navigationController?.visibleViewController?.navigationItem.titleView = searchBar
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
        let XIBCell = UINib.init(nibName: "SearchItem", bundle: nil)
        tableView.register(XIBCell, forCellReuseIdentifier: "SearchItem")
        tableView.delegate = self
        tableView.dataSource = self
        
        definesPresentationContext = true
        automaticallyAdjustsScrollViewInsets = false
    }
}

extension SearchViewController : UISearchBarDelegate {
    //Text on change function for searchbar.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) -> Void {
        self.filterContentForSearchText(searchText)
    }
    
    //Filter data in tableview.
    func filterContentForSearchText(_ searchText: String) -> Void {
        //Clear list on each text query.
        games.removeAll()
        users.removeAll()
        
        //Fetch games, users, and teams.
        when(fulfilled: MyFSRef.getGames(), MyFSRef.getUsersFromSearch(category: "userName", search: searchText, numberOfUsers: 25))
            .then{ (result) -> Void in
                if(searchText == ""){
                    //Clear results from table view.
                    self.filteredGames.removeAll()
                    self.filteredUsers.removeAll()
                    self.filteredTeams.removeAll()
                    self.tableView.reloadData()
                    return
                }
                
                //Set games
                for game in result.0 {
                    let homeTeam: NBATeam = NBATeamService.instance.teams.filter{ $0.name == game.homeTeamName }.first!
                    let awayTeam: NBATeam = NBATeamService.instance.teams.filter{ $0.name == game.awayTeamName }.first!
                    
                    let gameItem: Item = Item()
                    gameItem.id = game.id
                    gameItem.imageDownloadUrl = homeTeam.imageDownloadUrl
                    gameItem.name = homeTeam.name + " vs. " + awayTeam.name
                    gameItem.group = self.categories[0]
                    self.games.append(gameItem)
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
            
                self.tableView.reloadData()
            }.always{}
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
        let items: [Item] = itemsInCategory(indexPath.section)
        let item: Item = items[indexPath.row]
        return item
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
                //Text will still be present in searchbar on return if not cleared like such
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
}

extension SearchViewController : SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) -> Void {
        controller.dismiss(animated: true, completion: nil)
    }
}




