import UIKit

class AdminTableViewController: UITableViewController {
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    
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


