import UIKit

class EvaluateGameViewController : UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var winnerPic: UIImageView!
    @IBOutlet weak var winnerName: UILabel!
    @IBOutlet weak var info: UILabel!

    var game: Game?
    var games: [Game] = [Game]()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(EvaluateGameViewController.getGames), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        getGames()
    }
    
    func initUI() -> Void {
        hideKeyboardWhenTappedAround()
        
        //Register cell for table.
        tableView.register(UINib.init(nibName: "GameTableViewCell", bundle: nil), forCellReuseIdentifier: "GameTableViewCell")
        
        //Set delegate and data source.
        tableView.dataSource = self
        tableView.delegate = self
        
        //Add refresh control.
        tableView.addSubview(refreshControl)
    }
    
    @objc func getGames() -> Void {
        MyFSRef.getGamesByStatus(status: 2)
            .then{ (games) -> Void in
                self.games = games
                self.tableView.reloadData()
            }.always {
                self.refreshControl.endRefreshing()
        }
    }
    
    @IBAction func finish() -> Void {
        if let _ = game {
            ModalService.showAlert(title: "Finish", message: "Coming Soon...", vc: self)
        }else{
            ModalService.showAlert(title: "Select A Game First", message: "", vc: self)
        }
    }
}

extension EvaluateGameViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        game = games[indexPath.row]
        
        MyFSRef.getBetsForGame(gameId: game!.id)
            .then{ bets -> Void in
                let winnerUserId: String = self.getWinner(bets: bets)
                MyFSRef.getUserById(id: winnerUserId)
                    .then{ user -> Void in
                        
                        self.winnerPic.round(borderWidth: 0, borderColor: UIColor.black)
                        self.winnerPic.kf.setImage(with: URL(string: user.imageDownloadUrl))
                        
                        self.winnerName.text = user.userName + " Won"
                        
                        self.info.text = user.id == self.game!.userId ? "Owner" : "Better"
                        
                    }.always{}
            }.always{}
    }
    
    //Return userId of winner.
    func getWinner(bets: [Bet]) -> String {
        for bet in bets {
            //This bet has won the game
            if bet.homeDigit == self.game!.homeTeamScore % 10 && bet.awayDigit == self.game!.awayTeamScore % 10 {
                return bet.userId
            }
        }
        //Owner of the game is the winner
        return self.game!.userId
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "GameTableViewCell", for: indexPath as IndexPath) as? GameTableViewCell{
            let game: Game = games[indexPath.row]
            
            let ht = NBATeams.all.filter{ $0.name == game.homeTeam }.first!
            let at = NBATeams.all.filter{ $0.name == game.awayTeam }.first!
            
            cell.title.text = ht.name + " vs. " + at.name
            cell.potAmount.text = "(Pot Amount Will Go Here)"
            cell.betCount.text = "(Bet Count Will Go Here)"
            
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
            cell.homeTeamImage.kf.setImage(with: URL(string: ht.imageDownloadUrl))
            cell.awayTeamImage.round(borderWidth: 0, borderColor: UIColor.black)
            cell.awayTeamImage.kf.setImage(with: URL(string: at.imageDownloadUrl))
            
            return cell
        }
        fatalError("Unable to Dequeue Reusable Supplementary View")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
}


