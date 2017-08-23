import UIKit

class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reInitUI()
    }

    func initUI() -> Void {
    }
    
    func reInitUI() -> Void {
        self.tabBarController?.navigationItem.title = "Profile"
    }
}

