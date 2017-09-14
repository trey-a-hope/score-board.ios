import SwiftSpinner
import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var homeTeamImage: UIImageView!
    @IBOutlet weak var awayTeamImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var gameBundles: [(game: Game, bets: [Bet])]!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(HomeViewController.loadHomeData), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(ConnectionManager.isConnectedToInternet()){
            loadHomeData()
        }else{
            ModalService.showError(title: "Error", message: "No internet connection.")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reInitUI()
    }
    
    func loadHomeData() -> Void {
        SwiftSpinner.show("Loading Home Page...")
        
        self.scrollView.addSubview(self.refreshControl)
        getGameBundles()
    }
    
    func getGameBundles() -> Void {
        
        MyFirebaseRef.getGames()
            .then{ (gameBundles) -> Void in
                self.gameBundles = gameBundles
                
                self.initUI()
            }.catch{ (error) in
                
            }.always{
                SwiftSpinner.hide()
                self.refreshControl.endRefreshing()
            }
        
    }
    
    func initUI() -> Void {
        let randomNum:UInt32 = arc4random_uniform(UInt32(self.gameBundles.count)) // range is 0 to 99
        let topGame: Game = self.gameBundles[Int(randomNum)].game
        
        let homeTeam = NBATeamService.instance.getTeam(id: topGame.homeTeamId)
        let awayTeam = NBATeamService.instance.getTeam(id: topGame.awayTeamId)
        
        homeTeamImage.round(0, UIColor.black)
        homeTeamImage.kf.setImage(with: URL(string: homeTeam.imageDownloadUrl))
        
        awayTeamImage.round(0, UIColor.black)
        awayTeamImage.kf.setImage(with: URL(string: awayTeam.imageDownloadUrl))
    }
    
    func reInitUI() -> Void {
        self.navigationController?.visibleViewController?.title = "ScorBord"
        setNavBarButtons()
    }
    
    func setNavBarButtons() -> Void {
        self.navigationController?.visibleViewController?.navigationItem.setRightBarButtonItems([], animated: true)
    }
}

