import UIKit

class AdminTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.visibleViewController?.navigationItem.setRightBarButtonItems([], animated: true)
    }
    
    func initUI() -> Void {
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        switch(indexPath.section){
            //Games
            case 0:
                switch(indexPath.row){
                    //Add game
                    case 0:
                        let addGameViewController = storyBoard.instantiateViewController(withIdentifier: "AddGameViewController") as! AddGameViewController
                        navigationController?.pushViewController(addGameViewController, animated: true)
                        break
                    //Update Game
                    case 1:
                        let updateGameViewController = storyBoard.instantiateViewController(withIdentifier: "UpdateGameViewController") as! UpdateGameViewController
                        navigationController?.pushViewController(updateGameViewController, animated: true)
                        break
                    //Evaluate game
                    case 2:
                        let evaluateGameViewController = storyBoard.instantiateViewController(withIdentifier: "EvaluateGameViewController") as! EvaluateGameViewController
                        navigationController?.pushViewController(evaluateGameViewController, animated: true)
                        break
                    //Delete Game
                    case 3:
                        ModalService.showAlert(title: "Delete Game", message: "Coming Soon...", vc: self)
                    default:break
                }
                break
            //Users
            case 1:
                switch(indexPath.row){
                    //Delete User
                    case 0:
                        ModalService.showAlert(title: "Delete User", message: "Coming Soon...", vc: self)
                        break
                    default:break
                }
                break
            default:break
        }
    }
}


