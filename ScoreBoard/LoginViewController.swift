import Material
import Firebase
import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var emailText: TextField!
    @IBOutlet weak var passwordText: TextField!
    @IBOutlet weak var forgotPassword: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(SessionManager.isLoggedIn()){
            goToHome()
        }
        
        initUI()
    }
    
    func initUI() -> Void {
        spinner.isHidden = true
        
        hideKeyboardWhenTappedAround()
        
        signupLabel.isUserInteractionEnabled = true
        signupLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoginViewController.goToSignup)))
        
        forgotPassword.isUserInteractionEnabled = true
        forgotPassword.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoginViewController.goToForgotPassword)))
    }
    
    @objc func goToSignup() -> Void {
        let signupViewController = storyBoard.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        navigationController!.pushViewController(signupViewController, animated: true)
    }
    
    @objc func goToForgotPassword() -> Void {
        ModalService.showResetPassword(vc: self)
            .then{(email) -> Void in
                //SwiftSpinner.show("Sending Email...")
                Auth.auth().sendPasswordReset(withEmail: email) { error in
                    if error != nil {
                        ModalService.showAlert(title: "Error", message: (error?.localizedDescription)!, vc: self)
                    }else{
                        ModalService.showAlert(title: "Email Sent", message: "Check your inbox for instructions on how to reset your password.", vc: self)
                    }
                }
            }.always {}
    }
    
     @IBAction func loginAction(_ sender: UIButton) -> Void {
        let email: String = emailText.text!
        let password: String = passwordText.text!

        spinner.isHidden = false
        spinner.startAnimating()
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            //If error, display message
            if error != nil {
                self.spinner.isHidden = true
                self.spinner.stopAnimating()
                ModalService.showAlert(title: "Error", message: (error?.localizedDescription)!, vc: self)
                return
            }

            MyFSRef.getUserByEmail(email: email)
                .then{ (user) -> Void in
                    SessionManager.setUserId(user.id)
                    self.goToHome()
                }
                .catch{ (error) in
                    Auth.auth().currentUser?.delete(completion: { (err) in
                        if err != nil {
                            ModalService.showAlert(title: "Error", message: (error.localizedDescription), vc: self)
                        }
                    })
                    ModalService.showAlert(title: "Error", message: "Could not find profile.", vc: self)
                }.always{
                    self.spinner.isHidden = true
                    self.spinner.stopAnimating()
            }
        })
        
    }
    
    func goToHome() -> Void {
//        let homeTabBarController = storyBoard.instantiateViewController(withIdentifier: "HomeTabBarController") as! HomeTabBarController
//        navigationController?.pushViewController(homeTabBarController, animated: true)
        
        if let nav = self.navigationController {
            var stack: [UIViewController] = nav.viewControllers
            stack.remove(at: 0)
            let homeTabBarController = storyBoard.instantiateViewController(withIdentifier: "HomeTabBarController") as! HomeTabBarController
            nav.pushViewController(homeTabBarController, animated: true)
            nav.setViewControllers([homeTabBarController], animated: true)
        }
    }
}
