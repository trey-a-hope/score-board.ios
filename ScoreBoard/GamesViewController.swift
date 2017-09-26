import Firebase
import UIKit

class GamesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var games: [Game] = [Game]()
    
    //Database reference to all games.
    private var gamesRef: DatabaseReference = Database.database().reference().child("Games")
    //Handle that will track any data changes to the games.
    private var gameUpdateRefHandle: DatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(ConnectionManager.isConnectedToInternet()){
            initUI()
            getGames()
        }else{
            ModalService.showError(title: "Error", message: "No internet connection.")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reInitUI()
    }
    
    func initUI() -> Void {
        //Register cell for table.
        let XIBCell = UINib.init(nibName: "GameTableViewCell", bundle: nil)
        tableView.register(XIBCell, forCellReuseIdentifier: "GameTableViewCell")
        
        //Set delegate and data source.
        tableView.dataSource = self
        tableView.delegate = self
        
        //Configure UISegmentControl
        segmentedControl.tintColor = Constants.primaryColor
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for:.allEvents)
    }
    
    func reInitUI() -> Void {
        //Set title of view.
        self.navigationController?.visibleViewController?.title = "Games"
        setNavBarButtons()
    }
    
    func getGames() -> Void {
        //Fetch games and observe any changes at any time.
        gameUpdateRefHandle = gamesRef.observe(.value, with: { (gameSnapshots) -> Void in
            self.games.removeAll()
            
            gameSnapshots.children.allObjects.forEach({ (gameSnapshot) in
                self.games.append(MyFirebaseRef.extractGameData(gameSnapshot: gameSnapshot as! DataSnapshot))
            })

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
            
            self.tableView.reloadData()
        })
    }
    
    func setNavBarButtons() -> Void {
        self.navigationController?.visibleViewController?.navigationItem.setRightBarButtonItems([], animated: true)
    }
    
    func segmentedControlValueChanged() -> Void {
        getGames()
    }
    
    deinit {
        if let refHandle = gameUpdateRefHandle {
            gamesRef.removeObserver(withHandle: refHandle)
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
            
            let homeTeam: NBATeam = NBATeamService.instance.getTeam(id: game.homeTeamId)
            let awayTeam: NBATeam = NBATeamService.instance.getTeam(id: game.awayTeamId)

            cell.title.text = homeTeam.name + " vs. " + awayTeam.name
            cell.potAmount.text = String(format: "$%.02f", game.potAmount) + " pot"
            cell.homeTeamImage.round(0, UIColor.black)
            cell.homeTeamImage.kf.setImage(with: URL(string: homeTeam.imageDownloadUrl))
            cell.awayTeamImage.round(0, UIColor.black)
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
        //let game: Game = games[editActionsForRowAt.row]
        
        //Mute conversation button.
        let mute = UITableViewRowAction(style: .normal, title: "Mute") { action, index in
//            let popup = PopupDialog(title: "Mute Thread with " + conversation.recipientname, message: "Are you sure?")
//            popup.addButtons([
//                DefaultButton(title: "YES") {
//                    ModalService.displayToast("Mute Thread", UIColor.gray)
//                }, CancelButton(title: "CANCEL") {
//                }
//                ])
//            self.present(popup, animated: true, completion: nil)
        }
        mute.backgroundColor = .gray
        
        //Delete conversation button.
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
//            let popup = PopupDialog(title: "Delete Thread with " + conversation.recipientname, message: "Are you sure?")
//            popup.addButtons([
//                DefaultButton(title: "YES") {
//                    ModalService.displayToast("Delete Thread", UIColor.gray)
//                }, CancelButton(title: "CANCEL") {
//                }
//                ])
//            self.present(popup, animated: true, completion: nil)
        }
        delete.backgroundColor = .red
        
        return [delete, mute]
    }

}




