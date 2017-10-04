import Material
import UIKit

class TakeGameViewController: UIViewController {
    @IBOutlet weak var homeTeamLabel: UILabel!
    @IBOutlet weak var homeTeamImage: UIImageView!
    @IBOutlet weak var awayTeamLabel: UILabel!
    @IBOutlet weak var awayTeamImage: UIImageView!
    @IBOutlet weak var potAmount: TextField!
    @IBOutlet weak var pricePerBet: TextField!
    
    var gameId: String!
    var game: Game!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getGame()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Set title of view.
        navigationController?.visibleViewController?.navigationItem.titleView = nil
        navigationController?.visibleViewController?.title = "Take Game"
        navigationController?.visibleViewController?.navigationItem.setRightBarButtonItems([], animated: true)
    }
    
    func getGame() -> Void {
        MyFSRef.getGame(gameId: gameId)
            .then{ (game) -> Void in
                self.game = game
                self.initUI()
            }.catch{ (error) in
                ModalService.showError(title: "Error", message: error.localizedDescription)
            }.always{}
    }
    
    func initUI() -> Void {
        hideKeyboardWhenTappedAround()
        
        let homeTeam: NBATeam = NBATeamService.instance.teams.filter({ $0.name == game.homeTeamName}).first!
        let awayTeam: NBATeam = NBATeamService.instance.teams.filter({ $0.name == game.awayTeamName}).first!
        
        homeTeamLabel.text = homeTeam.name
        homeTeamImage.round(borderWidth: 0, borderColor: UIColor.black)
        homeTeamImage.kf.setImage(with: URL(string: homeTeam.imageDownloadUrl))
        awayTeamLabel.text = awayTeam.name
        awayTeamImage.round(borderWidth: 0, borderColor: UIColor.black)
        awayTeamImage.kf.setImage(with: URL(string: awayTeam.imageDownloadUrl))
    }
}
