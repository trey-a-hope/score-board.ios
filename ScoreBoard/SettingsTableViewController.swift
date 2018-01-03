import PromiseKit
import UIKit

class SettingsTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.visibleViewController?.navigationItem.titleView = nil
        navigationController?.visibleViewController?.navigationItem.title = "Settings"
        navigationController?.visibleViewController?.navigationItem.setRightBarButtonItems([], animated: true)
        navigationController?.isNavigationBarHidden = false
        navigationController?.hidesBarsOnSwipe = false
    }
    
    func initUI() -> Void {

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        switch(indexPath.section){
            //Help
            case 0:
                switch (indexPath.row) {
                    //About
                    case 0:
                        let aboutViewController = storyBoard.instantiateViewController(withIdentifier: "AboutViewController") as! AboutViewController
                        navigationController?.pushViewController(aboutViewController, animated: true)
                        break
                    //Support
                    case 1:
                        let supportViewController = storyBoard.instantiateViewController(withIdentifier: "SupportViewController") as! SupportViewController
                        navigationController?.pushViewController(supportViewController, animated: true)
                        break
                    default: break
                }
            //Account
            case 1:
                switch (indexPath.row) {
                    //Change Email
                    case 0:
                        let changeEmailViewController = storyBoard.instantiateViewController(withIdentifier: "ChangeEmailViewController") as! ChangeEmailViewController
                        navigationController?.pushViewController(changeEmailViewController, animated: true)
                        break
                    //Change Password
                    case 1:
                        let changePasswordViewController = storyBoard.instantiateViewController(withIdentifier: "ChangePasswordViewController") as! ChangePasswordViewController
                        navigationController?.pushViewController(changePasswordViewController, animated: true)
                        break
                    //Notifications
                    case 2:
                        ModalService.showAlert(title: "Notifications", message: "Coming Soon...", vc: self)
                        break
                    //Log Out
                    case 3:
                        ModalService.showConfirm(title: "Log out", message: "Are you sure?", vc: self)
                            .then{() -> Void in
                                SessionManager.signOut()
                                _ = self.navigationController?.popViewController(animated: true)
                            }.always{}
                        break
                    //Delete Account
                    case 4:
                        ModalService.showConfirm(title: "Delete Account", message: "Before you can delete your account, you must wait for any games you currently own to finish.", vc: self)
                            .then{(x) -> Void in
                                MyFSRef.deleteUser(userId: SessionManager.getUserId())
                                    .then{ () -> Void in
                                        _ = self.navigationController?.popViewController(animated: true)
                                    }.catch{ (error) in
                                        ModalService.showAlert(title: "Error", message: error.localizedDescription, vc: self)
                                    }.always {}
                            }.always{}
                        break
                    default:break
                }
                break
            //Payment
            case 2:
                switch (indexPath.row) {
                    //Method
                    case 0:
                        let paymentMethodViewController = storyBoard.instantiateViewController(withIdentifier: "PaymentMethodViewController") as! PaymentMethodViewController
                        navigationController?.pushViewController(paymentMethodViewController, animated: true)
                        break
                    //History
                    case 1:
                        let paymentHistoryTableViewController = storyBoard.instantiateViewController(withIdentifier: "PaymentHistoryTableViewController") as! PaymentHistoryTableViewController
                        navigationController?.pushViewController(paymentHistoryTableViewController, animated: true)
                        break
                    default:break
                }
                break
            default: break
        }
    }

}

