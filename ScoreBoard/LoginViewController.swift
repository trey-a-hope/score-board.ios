import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var homeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeButton.addTarget(
            self,
            action: #selector(LoginViewController.goToHome),
            for: UIControlEvents.touchUpInside)
    }
    
    func goToHome() -> Void {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let homeTabBarController = storyBoard.instantiateViewController(withIdentifier: "HomeTabBarController") as! HomeTabBarController
        self.navigationController!.pushViewController(homeTabBarController, animated: true)
    }

}

