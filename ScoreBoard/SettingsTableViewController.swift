import PopupDialog
import UIKit

class SettingsTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(ConnectionManager.isConnectedToInternet()){
            initUI()
        }else{
            ModalService.displayNoInternetAlert(vc: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reInitUI()
    }
    
    func initUI() -> Void {

    }
    
    func reInitUI() -> Void {
        self.navigationController?.visibleViewController?.title = "Settings"
    }
    
    func signout() -> Void {
        SessionManager.signOut()
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let loginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController!.pushViewController(loginViewController, animated: true)
        self.navigationController?.setViewControllers([loginViewController], animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        switch(indexPath.section){
            /* Account */
            case 0:
                switch (indexPath.row) {
                    /* Log Out */
                    case 0:
                        let popup = PopupDialog(title: "Log out", message: "Are you sure?")
                        popup.addButtons([
                            DefaultButton(title: "YES") {
                                self.signout()
                            },
                            CancelButton(title: "CANCEL") {}
                        ])
                        self.present(popup, animated: true, completion: nil)
                    default: break
                }
            default: break
        }
    }

}

