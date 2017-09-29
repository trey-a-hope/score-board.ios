import SafariServices
import UIKit

class Item {
    var id: String!
    var url: String!
    var group: String!
    var imageDownloadUrl: String!
    var name: String!
}

class SearchViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var defaultLabel: UILabel!
    
    let searchBar: UISearchBar = UISearchBar()
    
    //Navbar buttons
    var searchButton: UIBarButtonItem!
    
    //All search categories
    var games: [Item] = [Item]()
    var filteredGames: [Item] = [Item]()
    var users: [Item] = [Item]()
    var filteredUsers: [Item] = [Item]()
    var teams: [Item] = [Item]()
    var filteredTeams: [Item] = [Item]()
    
    var categories: [String] = ["Games", "Users", "Teams"]
    
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
        
//        NotificationCenter.default.addObserver(self, selector: "keyboardWillShow:", name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
//    func keyboardWillShow(_ notification: Notification) {
//        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
//            let keyboardRectangle = keyboardFrame.cgRectValue
//            let keyboardHeight = keyboardRectangle.height
//            print(keyboardHeight) 216 - 48 = 118
//        }
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        thisVC.title = "Search"
        
        searchButton.isEnabled = ConnectionManager.isConnectedToInternet()
        
        thisVC.navigationItem.setLeftBarButtonItems([], animated: true)
        thisVC.navigationItem.setRightBarButtonItems([searchButton], animated: true)
    }
    
    func initUI() -> Void {
        hideKeyboardWhenTappedAround()
        
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
        
        //Configure Table View
        let XIBCell = UINib.init(nibName: "SearchItem", bundle: nil)
        tableView.register(XIBCell, forCellReuseIdentifier: "SearchItem")
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        
        //Set games
        //Set users
        //Set teams
        for team in NBATeamService.instance.teams {
            let i: Item = Item()
            i.imageDownloadUrl = team.imageDownloadUrl
            i.name = team.city + " " + team.name
            i.group = categories[2]
            i.url = team.url
            teams.append(i)
        }
        filteredTeams = teams
        
        tableView.reloadData()
        
    }
}

extension SearchViewController : UISearchBarDelegate {
    //Show search bar
    func showSearchBar(_ sender: UIBarButtonItem!) -> Void {
        defaultLabel.isHidden = true
        tableView.isHidden = false
        
        thisVC.navigationItem.setHidesBackButton(true, animated:true)
        thisVC.navigationItem.titleView = searchBar
        thisVC.navigationItem.rightBarButtonItems = nil
        thisVC.navigationItem.leftBarButtonItems = nil
    }
    
    //Hide search bar
    func hideSearchBar() -> Void {
        defaultLabel.isHidden = false
        tableView.isHidden = true
        
        //Reset filtered values to original
        filteredGames = games
        filteredUsers = users
        filteredTeams = teams
        tableView.reloadData()
        
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
        if(searchText == ""){
            filteredGames = games
            filteredUsers = users
            filteredTeams = teams
            tableView.reloadData()
            return
        }
        
        filteredGames = games.filter { game in
            return game.name.lowercased().range(of: searchText.lowercased()) != nil
        }
        
        filteredUsers = users.filter { user in
            return user.name.lowercased().range(of: searchText.lowercased()) != nil
        }
        
        filteredTeams = teams.filter { team in
            return team.name.lowercased().range(of: searchText.lowercased()) != nil
        }
        
        tableView.reloadData()
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
        
        switch(item.group){
            //Teams
            case categories[2]:
                let svc = SFSafariViewController(url: NSURL(string: item.url)! as URL)
                svc.delegate = self
                svc.preferredBarTintColor = Constants.primaryColor
                svc.preferredControlTintColor = .white
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
    
//    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
//        let user: User = getUserFromIndexPath(editActionsForRowAt)
//
//        switch(user.roleId){
//        //Athlete
//        case 1:
//            if let _  = user.firstPlayerPositionId, let _ = user.secondaryPlayerPositionId {
//                //1st Position
//                let firstPosition: String = PlayerPositionService.getPlayerPositionAbbreviation(user.firstPlayerPositionId!)
//                let firstPositionButton = UITableViewRowAction(style: .normal, title: firstPosition) { action, index in
//
//                }
//                firstPositionButton.backgroundColor = GMColor.blue800Color()
//                //2nd Position
//                let secondPosition: String = PlayerPositionService.getPlayerPositionAbbreviation(user.secondaryPlayerPositionId!)
//                let secondPositionButton = UITableViewRowAction(style: .normal, title: secondPosition) { action, index in
//
//                }
//                secondPositionButton.backgroundColor = GMColor.orange800Color()
//
//                return [secondPositionButton, firstPositionButton]
//            }
//            return []
//        //High School Coach
//        case 2:
//            return []
//        //College Coach
//        case 3:
//            return []
//        default:
//            return []
//        }
//    }
}

extension SearchViewController : SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) -> Void {
        controller.dismiss(animated: true, completion: nil)
    }
}




