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
        
        if(SessionManager.isLoggedIn()){
            goToHome()
        }
        
        initUI()

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
            ModalService.displayAlert(title: "Error", message: "Invalid email", vc: self)
        }
        else{
            SwiftSpinner.show("Logging in...")
            Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                /* If error, display message. */
                if error != nil {
                    SwiftSpinner.hide()
                    ModalService.displayAlert(title: "Error", message: (error?.localizedDescription)!, vc: self)
                    return
                }
                
                MyFirebaseRef.getUserByEmail(email: email).then{ (user) -> Void in
                    SessionManager.setUserId(user.id)
                    ModalService.displayAlert(title: "Success", message: "Proceed to Login", vc: self)
                    //_ = self.navigationController?.popViewController(animated: true)
                    }.catch{ (error) in
                        Auth.auth().currentUser?.delete(completion: { (err) in
                            if err != nil {
                                ModalService.displayAlert(title: "Error", message: (err?.localizedDescription)!, vc: self)
                            }
                        })
                        ModalService.displayAlert(title: "Could not find profile.", message: "Please sign up first.", vc: self)
                    }.always{
                        SwiftSpinner.hide()
                }
            })
        }
        
        print(email)
        print(password)
    }
    
    
    func goToHome() -> Void {
        if let nav = self.navigationController {
            var stack: [UIViewController] = nav.viewControllers
            stack.removeAll()
            nav.setViewControllers(stack, animated: true)
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let homeTabBarController = storyBoard.instantiateViewController(withIdentifier: "HomeTabBarController") as! HomeTabBarController
            nav.pushViewController(homeTabBarController, animated: true)
        }
    }
}
