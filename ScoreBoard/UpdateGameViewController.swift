import Material
import UIKit

class UpdateGameViewController : UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var homeScore: TextField!
    @IBOutlet weak var homeStepper: UIStepper!
    @IBOutlet weak var awayScore: TextField!
    @IBOutlet weak var awayStepper: UIStepper!
    @IBOutlet weak var status: UISegmentedControl!
    
    var selectedGame: Game?
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
        MyFSRef.getGames()
            .then{ (games) -> Void in
                self.games = games
                self.tableView.reloadData()
            }.always {
                self.refreshControl.endRefreshing()
        }
    }
    
    @IBAction func save() -> Void {
        if let g = selectedGame {
            MyFSRef.updateGame(gameId: g.id, status: status.selectedSegmentIndex, homeTeamScore: Int(homeStepper.value), awayTeamScore: Int(awayStepper.value))
                .then{ () -> Void in
                    ModalService.showAlert(title: "Game Updated", message: "", vc: self)
                }.catch{ error in
                    ModalService.showAlert(title: "Error", message: error.localizedDescription, vc: self)
                }.always{}
        }else{
            ModalService.showAlert(title: "Pick A Game First", message: "", vc: self)
        }
    }
    
    @IBAction func homeDigitStepperAction(sender: UIStepper) {
        homeScore.text = "\(Int(homeStepper.value))"
    }
    
    @IBAction func awayDigitStepperAction(sender: UIStepper) {
        awayScore.text = "\(Int(awayStepper.value))"
    }
}

extension UpdateGameViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedGame = games[indexPath.row]
        
        status.selectedSegmentIndex = selectedGame!.status
        homeScore.text = String(describing: selectedGame!.homeTeamScore!)
        homeStepper.value = Double(selectedGame!.homeTeamScore!)
        awayScore.text = String(describing: selectedGame!.awayTeamScore!)
        awayStepper.value = Double(selectedGame!.awayTeamScore!)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "GameTableViewCell", for: indexPath as IndexPath) as? GameTableViewCell{
            let game: Game = games[indexPath.row]
            
            let homeTeam: NBATeam = NBATeamService.instance.teams.filter({ $0.id == game.homeTeamId }).first!
            let awayTeam: NBATeam = NBATeamService.instance.teams.filter({ $0.id == game.awayTeamId }).first!
            
            cell.title.text = homeTeam.name + " vs. " + awayTeam.name
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
            cell.homeTeamImage.kf.setImage(with: URL(string: homeTeam.imageDownloadUrl))
            cell.awayTeamImage.round(borderWidth: 0, borderColor: UIColor.black)
            cell.awayTeamImage.kf.setImage(with: URL(string: awayTeam.imageDownloadUrl))
            
            return cell
        }
        fatalError("Unable to Dequeue Reusable Supplementary View")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
}

