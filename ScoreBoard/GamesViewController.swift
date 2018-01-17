import Firebase
import UIKit

class GamesViewController: UIViewController {
    @IBOutlet private weak var tableView        : UITableView!
    @IBOutlet private weak var segmentedControl : UISegmentedControl!
    
    private var allGames                        : [Game] = [Game]()
    private var games                           : [Game] = [Game]()
    
    private lazy var refreshControl: UIRefreshControl = {
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
        
        navigationController?.visibleViewController?.navigationItem.titleView = nil
        navigationController?.visibleViewController?.navigationItem.title = "Games"
        navigationController?.visibleViewController?.navigationItem.setRightBarButtonItems([], animated: true)
        navigationController?.isNavigationBarHidden = false
        navigationController?.hidesBarsOnSwipe = false
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
    
    @objc func getGames() -> Void {
        MyFSRef.getAllGames()
            .then{ (games) -> Void in
                self.allGames = games
                self.sectionGames()
            }.always {
                self.refreshControl.endRefreshing()
            }
    }
    
    @objc func sectionGames() -> Void {
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
            
            let homeTeam: NBATeam = NBATeamService.instance.teams.filter({ $0.id == game.homeTeamId }).first!
            let awayTeam: NBATeam = NBATeamService.instance.teams.filter({ $0.id == game.awayTeamId }).first!

            cell.title.text = homeTeam.name + " vs. " + awayTeam.name
            
            //Game taken
            if game.userId != nil {
                cell.potAmount.text = String(format: "$%.02f", game.potAmount) + " pot"
                cell.betCount.text = String(format: "$%.02f", game.betPrice) + " bets"
            }
            //Game empty
            else{
                cell.potAmount.text = "No pot set"
                cell.betCount.text = "No bets"
            }
            
            switch(game.status){
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
            let textToShare = "Check out this game I'm betting on in ScorBord!"
            if let myWebsite = NSURL(string: "www.google.com") {
                let objectsToShare = [textToShare, myWebsite] as [Any]
                let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                self.present(activityViewController, animated: true, completion: nil)
            }else{
                //TODO: DISPLAY MODAL SAYING LINK IS MALFORMED
            }
        }
        share.backgroundColor = GMColor.green500Color()
        
        return [share]
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return Constants.GAME_CELL_HEIGHT
    }
}




