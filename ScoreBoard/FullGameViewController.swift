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
        self.title = "Hawks vs. Celtics"
    }
    
    func getGame() -> Void {
        SwiftSpinner.show("Loading game...")
        MyFirebaseRef.getGame(gameId: gameId!)
            .then{ (game) -> Void in
                self.game = game
                print(self.game)
            }.catch{ (error) in
                
            }
            .always {
                SwiftSpinner.hide()
            }
    }
}


