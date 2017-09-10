import SwiftSpinner
import UIKit

class SettingsTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(ConnectionManager.isConnectedToInternet()){
            initUI()
        }else{
            ModalService.showError(title: "Error", message: "No internet connection.")
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
        setNavBarButtons()
    }
    
    func setNavBarButtons() -> Void {
        self.navigationController?.visibleViewController?.navigationItem.setRightBarButtonItems([], animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        switch(indexPath.section){
            /* Account */
            case 0:
                switch (indexPath.row) {
                    /* Log Out */
                    case 0:
                        ModalService.showConfirm(title: "Log out", message: "Are you sure?", confirmText: "Yes", cancelText: "No")
                            .then{() -> Void in
                                SessionManager.signOut()
                                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                                let loginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                                self.navigationController!.pushViewController(loginViewController, animated: true)
                                self.navigationController?.setViewControllers([loginViewController], animated: true)
                            }.catch{ (error) in
                            }.always {
                            }
                        break
                    //Delete Account
                    case 1:
                        ModalService.showConfirm(title: "Delete Account", message: "Are you sure?", confirmText: "Yes", cancelText: "No")
                            .then{() -> Void in
                                
                                SwiftSpinner.show("Deleting Profile...")
                                MyFirebaseRef.deleteUser(userId: SessionManager.getUserId())
                                    .then{ () -> Void in
                                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                                        let loginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                                        self.navigationController!.pushViewController(loginViewController, animated: true)
                                        self.navigationController?.setViewControllers([loginViewController], animated: true)
                                    }.catch{ (error) in
                                        ModalService.showError(title: "Sorry", message: error.localizedDescription)
                                    }.always {
                                        SwiftSpinner.hide()
                                }
                                
                            }.catch{ (error) in
                            }.always {
                        }
                        break
                    default: break
                }
            default: break
        }
    }

}

