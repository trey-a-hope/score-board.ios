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
        
        //Add refresh control.
        tableView.addSubview(self.refreshControl)
        
        segmentedControl.tintColor = Constants.primaryColor
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for:.allEvents)
    }
    
    func reInitUI() -> Void {
        //Set title of view.
        self.navigationController?.visibleViewController?.title = "Games"
        setNavBarButtons()
    }
    
    func getGames() -> Void {
        //SwiftSpinner.show("Getting games...")
        MyFirebaseRef.getGames()
            .then{ (games) -> Void in
            self.games = games
                
            //Filter games by active code.
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
        }.catch{ (error) in
            ModalService.showError(title: "Error", message: error.localizedDescription)
        }
        .always {
            self.refreshControl.endRefreshing()
            //SwiftSpinner.hide()
        }
    }
    
    func setNavBarButtons() -> Void {
        self.navigationController?.visibleViewController?.navigationItem.setRightBarButtonItems([], animated: true)
    }
    
    func segmentedControlValueChanged() -> Void {
        getGames()
    }
}

extension GamesViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
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
            cell.start.text = ConversionService.convertDateToString(game.startDateTime, DateFormatter.Style.long)
            cell.homeTeamImage.round(0, UIColor.black)
            cell.homeTeamImage.kf.setImage(with: URL(string: homeTeam.imageDownloadUrl))
            cell.awayTeamImage.round(0, UIColor.black)
            cell.awayTeamImage.kf.setImage(with: URL(string: awayTeam.imageDownloadUrl))
            cell.betCount.text = String(describing: game.bets.count) + " bets"
            
            return cell
        }
        fatalError("Unable to Dequeue Reusable Supplementary View")
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let game: Game = games[editActionsForRowAt.row]
        
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




