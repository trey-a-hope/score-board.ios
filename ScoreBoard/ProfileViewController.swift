import SwiftSpinner
import UIKit

class ProfileViewController: UIViewController {
    var user: User = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(ConnectionManager.isConnectedToInternet()){
            getUser()
        }else{
            ModalService.displayNoInternetAlert(vc: self)
        }
    }
    
    func getUser() -> Void {
        print(SessionManager.getUserId())
        MyFirebaseRef.getUserByID(id: SessionManager.getUserId())
            .then{ (user) -> Void in
                self.user = user
                
                self.setProfileInfo()
            }.catch{ (error) in
                
            }.always{
                
            }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setProfileInfo()
    }

    func setProfileInfo() -> Void {
        self.navigationController?.visibleViewController?.title = user.userName
    }
}

