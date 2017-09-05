import SwiftSpinner
import UIKit

class FullGameViewController: UIViewController {
    public var gameId: String?
    private var game: Game = Game()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(ConnectionManager.isConnectedToInternet()){
            initUI()
            getGame()
        }else{
            ModalService.displayNoInternetAlert(vc: self)
        }
    }
    
    func initUI() -> Void {
    }
    
    func getGame() -> Void {
        SwiftSpinner.show("Loading game...")
        MyFirebaseRef.getGame(gameId: gameId!)
            .then{ (game) -> Void in
                self.game = game
                self.setTitle()
            }.catch{ (error) in
            }
            .always {
                SwiftSpinner.hide()
            }
    }
    
    func setTitle() -> Void {
        self.title = NBATeamService.getNBATeamName(id: game.homeTeamId) + " vs. " + NBATeamService.getNBATeamName(id: game.awayTeamId)
    }
}


