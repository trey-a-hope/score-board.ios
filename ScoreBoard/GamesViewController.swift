import Firebase
import UIKit

class GamesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
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
        segmentedControl.addTarget(self, action: #selector(getGames), for:.allEvents)
    }
    
    func getGames() -> Void {
        MyFSRef.getGames()
            .then{ (games) -> Void in
                self.games = games
                
                //Filter game by active state
                switch self.segmentedControl.selectedSegmentIndex {
                    //Pre Games
                    case 0:
                        self.games = self.games.filter { $0.activeCode == 0 }
                        break
                    //Active Games
                    case 1:
                        self.games = self.games.filter { $0.activeCode == 1 }
                        break
                    //Post Games
                    case 2:
                        self.games = self.games.filter { $0.activeCode == 2 }
                        break
                    default:break
                }
                
                //Reload table with fresh data
                self.tableView.reloadData()

            }.catch{ (error) in
                ModalService.showError(title: "Error", message: error.localizedDescription)
            }.always {
                self.refreshControl.endRefreshing()
            }
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
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let fullGameViewController = storyBoard.instantiateViewController(withIdentifier: "FullGameViewController") as! FullGameViewController
        fullGameViewController.gameId = game.id
        self.navigationController?.pushViewController(fullGameViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "GameTableViewCell", for: indexPath as IndexPath) as? GameTableViewCell{
            let game: Game = games[indexPath.row]
            
            let homeTeam: NBATeam = NBATeamService.instance.teams.filter({ $0.name == game.homeTeamName }).first!
            let awayTeam: NBATeam = NBATeamService.instance.teams.filter({ $0.name == game.awayTeamName }).first!

            cell.title.text = homeTeam.name + " vs. " + awayTeam.name
            cell.potAmount.text = String(format: "$%.02f", game.potAmount) + " pot"
            cell.homeTeamImage.round(borderWidth: 0, borderColor: UIColor.black)
            cell.homeTeamImage.kf.setImage(with: URL(string: homeTeam.imageDownloadUrl))
            cell.awayTeamImage.round(borderWidth: 0, borderColor: UIColor.black)
            cell.awayTeamImage.kf.setImage(with: URL(string: awayTeam.imageDownloadUrl))
            
            if(game.bets.count == 1){
                cell.betCount.text = "1 bet"
            }else{
                cell.betCount.text = String(describing: game.bets.count) + " bets"
            }
            
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
        share.backgroundColor = .blue

        return [share]
    }

}




