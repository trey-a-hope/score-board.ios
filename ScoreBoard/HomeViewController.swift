import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    
    var games: [Game]!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(HomeViewController.getGames), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(ConnectionManager.isConnectedToInternet()){
            scrollView.addSubview(self.refreshControl)
            
            getGames()
        }else{
            ModalService.showError(title: "Error", message: "No internet connection.")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reInitUI()
    }
    
    
    func getGames() -> Void {
        
        MyFirebaseRef.getGames()
            .then{ (games) -> Void in
                self.games = games
                
                self.initUI()
            }.catch{ (error) in
                
            }.always{
                //SwiftSpinner.hide()
                self.refreshControl.endRefreshing()
            }
        
    }
    
    func initUI() -> Void {
//        let randomNum: UInt32 = arc4random_uniform(UInt32(self.games.count))
//        let topGame: Game = self.games[Int(randomNum)]
//
//        let homeTeam = NBATeamService.instance.getTeam(id: topGame.homeTeamId)
//        let awayTeam = NBATeamService.instance.getTeam(id: topGame.awayTeamId)
//
//        homeTeamImage.round(0, UIColor.black)
//        homeTeamImage.kf.setImage(with: URL(string: homeTeam.imageDownloadUrl))
//
//        awayTeamImage.round(0, UIColor.black)
//        awayTeamImage.kf.setImage(with: URL(string: awayTeam.imageDownloadUrl))
    }
    
    func reInitUI() -> Void {
        navigationController?.visibleViewController?.navigationItem.titleView = nil
        navigationController?.visibleViewController?.title = "ScorBord"
        setNavBarButtons()
    }
    
    func setNavBarButtons() -> Void {
        navigationController?.visibleViewController?.navigationItem.setRightBarButtonItems([], animated: true)
    }
}

