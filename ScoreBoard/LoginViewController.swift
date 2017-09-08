import Material
import Firebase
import FirebaseDatabase
import SwiftSpinner
import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailText: TextField!
    @IBOutlet weak var passwordText: TextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if(SessionManager.isLoggedIn()){
            goToHome()
        }
    }
    
    func initUI() -> Void {
        self.hideKeyboardWhenTappedAround()
        
        loginButton.addTarget(
            self,
            action: #selector(LoginViewController.login),
            for: UIControlEvents.touchUpInside
        )
        
        signupLabel.isUserInteractionEnabled = true
        signupLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoginViewController.goToSignup)))
    }
    
    func goToSignup() -> Void {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let signupViewController = storyBoard.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        self.navigationController!.pushViewController(signupViewController, animated: true)
    }
    
    func login() -> Void {
        let email: String = emailText.text!
        let password: String = passwordText.text!
        
        if(!ValidityService.isValidEmail(email)){
            ModalService.showError(title: "Error", message: "Invalid email.")
        }
        else{
            SwiftSpinner.show("Logging in...")
            Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                /* If error, display message. */
                if error != nil {
                    SwiftSpinner.hide()
                    ModalService.showError(title: "Error", message: (error?.localizedDescription)!)
                    return
                }
                
                MyFirebaseRef.getUserByEmail(email: email)
                    .then{ (user) -> Void in
                        SessionManager.setUserId(user.id)
                        self.goToHome()
                    }
                    .catch{ (error) in
                        Auth.auth().currentUser?.delete(completion: { (err) in
                            if err != nil {
                                ModalService.showError(title: "Error", message: error.localizedDescription)
                            }
                        })
                        ModalService.showError(title: "Error", message: "Could not find profile.")

                    }.always{
                        SwiftSpinner.hide()
                }
            })
        }
    }
    
    
    func goToHome() -> Void {
        if let nav = self.navigationController {
            var stack: [UIViewController] = nav.viewControllers
            stack.remove(at: 0)
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let homeTabBarController = storyBoard.instantiateViewController(withIdentifier: "HomeTabBarController") as! HomeTabBarController
            nav.pushViewController(homeTabBarController, animated: true)
            nav.setViewControllers([homeTabBarController], animated: true)
        }
    }
}
