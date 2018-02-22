import PromiseKit
import SafariServices
import UIKit

internal class Item {
    var id: String!
    var url: String!
    var group: String!
    var imageDownloadUrl: String!
    var name: String!
    var gameOwnerId: String!//ID if the user who owns the game for game items
}
class SearchViewController: UIViewController {
    @IBOutlet private weak var tableView : UITableView!
    @IBOutlet private weak var spinner : UIActivityIndicatorView!
    @IBOutlet private weak var searchBar : UISearchBar!
    
    var items: [Item] = [Item]()
    
    var categories: [String] = ["Users", "Teams"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        setUpTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.visibleViewController?.navigationItem.titleView = nil
        navigationController?.visibleViewController?.navigationItem.title = "Search"
        navigationController?.visibleViewController?.navigationItem.setRightBarButtonItems([], animated: true)
        navigationController?.hidesBarsOnSwipe = true
    }
    
    override var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden ?? false
    }
    
    func initUI() -> Void {
        toggleSpinner(on: false)
        hideKeyboardWhenTappedAround()
        automaticallyAdjustsScrollViewInsets = false
        searchBar.delegate = self
    }
    
    func setUpTableView() -> Void {
        tableView.register(UINib.init(nibName: "SearchItem", bundle: nil), forCellReuseIdentifier: "SearchItem")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func toggleSpinner(on: Bool) -> Void {
        if on {
            spinner.isHidden = false
            spinner.startAnimating()
        }else{
            spinner.isHidden = true
            spinner.stopAnimating()
        }
    }
    
    @objc private func updateSearchTable() -> Void {
        toggleSpinner(on: true)
        
        items.removeAll()
        
        let searchText: String = searchBar.text!
        
        if !searchText.isEmpty {
            MyFSRef.getUsersFromSearch(category: "userName", search: searchText, numberOfUsers: 10).then{ users -> Void in
                //Users
                for user in users {
                    let userItem: Item = Item()
                    userItem.id = user.id
                    userItem.imageDownloadUrl = user.imageDownloadUrl
                    userItem.name = user.userName
                    userItem.group = self.categories[0]
                    self.items.append(userItem)
                }
                
                //Teams
                for team in NBATeams.all {
                    if team.name.lowercased().range(of:searchText.lowercased()) != nil {
                        let teamItem: Item = Item()
                        teamItem.imageDownloadUrl = team.imageDownloadUrl
                        teamItem.name = team.name
                        teamItem.group = self.categories[1]
                        teamItem.url = team.url
                        self.items.append(teamItem)
                    }
                }
                
                self.toggleSpinner(on: false)
                self.tableView.reloadData()
            }
        } else {
            toggleSpinner(on: false)
            self.items.removeAll()
            self.tableView.reloadData()
        }
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

extension SearchViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) -> Void {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(updateSearchTable), object: nil)
        perform(#selector(updateSearchTable), with: nil, afterDelay: 0.5)
    }
}

extension SearchViewController : UITableViewDataSource, UITableViewDelegate {
    func getItemFromIndexPath(_ indexPath: IndexPath) -> Item {
        return itemsInCategory(indexPath.section)[indexPath.row]
    }
    
    func itemsInCategory(_ index: Int) -> [Item] {
        switch(index){
            case 0:
                return items.filter{ $0.group == categories[0] }
            case 1:
                return items.filter{ $0.group == categories[1] }
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
                return items.filter{ $0.group == categories[0] }.count
            case 1:
                return items.filter{ $0.group == categories[1] }.count
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) -> Void {
        let item: Item = getItemFromIndexPath(indexPath)
        
        switch(indexPath.section){
            //Users
            case 0:
                let otherProfileViewController = storyBoard.instantiateViewController(withIdentifier: "OtherProfileViewController") as! OtherProfileViewController
                otherProfileViewController.userId = item.id
                navigationController!.pushViewController(otherProfileViewController, animated: true)
            //Teams
            case 1:
                let svc = SFSafariViewController(url: NSURL(string: item.url)! as URL)
                svc.delegate = self
                svc.preferredBarTintColor = Constants.primaryColor
                svc.preferredControlTintColor = .white
                svc.modalPresentationStyle = .formSheet
                svc.modalTransitionStyle = .crossDissolve
                present(svc, animated: true, completion: nil)
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
        if (searchBar.text?.isEmpty)! {
            return 0.0
        }else{
            return 30.0
        }
    }
}

extension SearchViewController : SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) -> Void {
        controller.dismiss(animated: true, completion: nil)
    }
}
