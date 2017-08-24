import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var signoutButton: UIButton!
    
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
        signoutButton.addTarget(
            self,
            action: #selector(SettingsViewController.signout),
            for: UIControlEvents.touchUpInside
        )
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
}

