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
            //Help
            case 0:
                switch (indexPath.row) {
                    //About
                    case 0:
                        ModalService.showInfo(title: "About", message: "Coming soon...")
                        break
                    //Support
                    case 1:
                        ModalService.showInfo(title: "Support", message: "Coming soon...")
                        break
                    default: break
                }
            //Account
            case 1:
                switch (indexPath.row) {
                    //Change Email
                    case 0:
                        ModalService.showInfo(title: "Change Email", message: "Coming soon...")
                        break
                    //Change Password
                    case 1:
                        ModalService.showInfo(title: "Change Password", message: "Coming soon...")
                        break
                    //Payment Method
                    case 2:
                        ModalService.showInfo(title: "Payment Method", message: "Coming soon...")
                        break
                    //Notifications
                    case 3:
                        ModalService.showInfo(title: "Notifications", message: "Coming soon...")
                        break
                    //Log Out
                    case 4:
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
                    case 5:
                        ModalService.showConfirm(title: "Delete Account", message: "Are you sure?", confirmText: "Yes", cancelText: "No")
                            .then{() -> Void in
                                MyFirebaseRef.deleteUser(userId: SessionManager.getUserId())
                                    .then{ () -> Void in
                                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                                        let loginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                                        self.navigationController!.pushViewController(loginViewController, animated: true)
                                        self.navigationController?.setViewControllers([loginViewController], animated: true)
                                    }.catch{ (error) in
                                        ModalService.showError(title: "Sorry", message: error.localizedDescription)
                                    }.always {}
                                
                            }.always {}
                        break
                    default:break
                }
                break
            default: break
        }
    }

}

