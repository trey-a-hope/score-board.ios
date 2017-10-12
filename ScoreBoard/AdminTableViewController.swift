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
                    //Delete game
                    case 1:
                        ModalService.showWarning(title: "Delete Game", message: "Coming soon...")
                        break
                    //Evaluate game
                    case 2:
                        let evaluateGameViewController = storyBoard.instantiateViewController(withIdentifier: "EvaluateGameViewController") as! EvaluateGameViewController
                        navigationController?.pushViewController(evaluateGameViewController, animated: true)
                        break
                    default:break
                }
                break
            //Users
            case 1:
                switch(indexPath.row){
                    //Delete User
                    case 0:
                        ModalService.showWarning(title: "Delete User", message: "Coming soon...")
                        break
                    default:break
                }
                break
            default:break
        }
    }
}


