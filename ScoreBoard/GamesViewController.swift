import Firebase
import UIKit

class GamesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    var allGames: [Game] = [Game]()
    var games: [Game] = [Game]()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(GamesViewController.getGames), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        getGames()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Set title of view.
        navigationController?.visibleViewController?.navigationItem.titleView = nil
        navigationController?.visibleViewController?.title = "Games"
        navigationController?.visibleViewController?.navigationItem.setRightBarButtonItems([], animated: true)
    }
    
    func initUI() -> Void {
        //Register cell for table.
        tableView.register(UINib.init(nibName: "GameTableViewCell", bundle: nil), forCellReuseIdentifier: "GameTableViewCell")
        
        //Set delegate and data source.
        tableView.dataSource = self
        tableView.delegate = self
        
        //Add refresh control.
        tableView.addSubview(refreshControl)
        
        //Configure UISegmentControl
        segmentedControl.tintColor = Constants.primaryColor
        segmentedControl.addTarget(self, action: #selector(sectionGames), for:.allEvents)
    }
    
    func getGames() -> Void {
        MyFSRef.getGames()
            .then{ (games) -> Void in
                self.allGames = games
                self.sectionGames()
            }.catch{ (error) in
                ModalService.showError(title: "Error", message: error.localizedDescription)
            }.always {
                self.refreshControl.endRefreshing()
            }
    }
    
    func sectionGames() -> Void {
        //Filter game by taken/active
        switch segmentedControl.selectedSegmentIndex {
            //Taken games
            case 0:
                games = allGames.filter { $0.userId != nil }
                break
            //Empty games
            case 1:
                games = allGames.filter { $0.userId == nil }
                break
            default:break
        }
        
        //Reload table with fresh data
        tableView.reloadData()
    }
}

extension GamesViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let game: Game = games[indexPath.row]

        //Game taken
        if game.userId != nil {
            let fullGameViewController = storyBoard.instantiateViewController(withIdentifier: "FullGameViewController") as! FullGameViewController
            fullGameViewController.gameId = game.id
            fullGameViewController.gameOwnerId = game.userId
            navigationController?.pushViewController(fullGameViewController, animated: true)
        }
        //Game empty
        else{
            let takeGameViewController = self.storyBoard.instantiateViewController(withIdentifier: "TakeGameViewController") as! TakeGameViewController
            takeGameViewController.gameId = game.id
            navigationController?.pushViewController(takeGameViewController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "GameTableViewCell", for: indexPath as IndexPath) as? GameTableViewCell{
            let game: Game = games[indexPath.row]
            
            let homeTeam: NBATeam = NBATeamService.instance.teams.filter({ $0.name == game.homeTeamName }).first!
            let awayTeam: NBATeam = NBATeamService.instance.teams.filter({ $0.name == game.awayTeamName }).first!

            cell.title.text = homeTeam.name + " vs. " + awayTeam.name
            
            //Game taken
            if game.userId != nil {
                cell.potAmount.text = String(format: "$%.02f", game.potAmount) + " pot"
                //cell.betCount.text = game.bets.count == 1 ? "1 bet" : String(describing: game.bets.count) + " bets"
                cell.betCount.text = "(Bet Count Will Go Here)"
            }
            //Game empty
            else{
                cell.potAmount.text = "No pot set"
                cell.betCount.text = "No bets"
            }
            
            switch(game.activeCode){
                case 0:
                    cell.statusBar.backgroundColor = GMColor.yellow500Color()
                    break
                case 1:
                    cell.statusBar.backgroundColor = GMColor.green500Color()
                    break
                case 2:
                    cell.statusBar.backgroundColor = GMColor.red500Color()
                    break
                default:break
            }
            
            cell.homeTeamImage.round(borderWidth: 0, borderColor: UIColor.black)
            cell.homeTeamImage.kf.setImage(with: URL(string: homeTeam.imageDownloadUrl))
            cell.awayTeamImage.round(borderWidth: 0, borderColor: UIColor.black)
            cell.awayTeamImage.kf.setImage(with: URL(string: awayTeam.imageDownloadUrl))
            
            return cell
        }
        fatalError("Unable to Dequeue Reusable Supplementary View")
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let game: Game = games[editActionsForRowAt.row]
        
        //Share button.
        let share = UITableViewRowAction(style: .normal, title: "Share") { action, index in
            ModalService.showInfo(title: "Share", message: "This game has " + String(describing: game.bets.count) + " bets.")
        }
        share.backgroundColor = GMColor.green500Color()
        
        return [share]
    }

}




