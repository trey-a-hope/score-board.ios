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
    
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

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
        spinner.isHidden = true
        
        hideKeyboardWhenTappedAround()
        
        signupLabel.isUserInteractionEnabled = true
        signupLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoginViewController.goToSignup)))
        
        forgotPassword.isUserInteractionEnabled = true
        forgotPassword.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoginViewController.goToForgotPassword)))
    }
    
    func goToSignup() -> Void {
        let signupViewController = storyBoard.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        navigationController!.pushViewController(signupViewController, animated: true)
    }
    
    func goToForgotPassword() -> Void {
        ModalService.showResetEmail(title: "Reset Password?", message: "We will send an email with instructions on reseting your password.")
            .then{(email) -> Void in
                //SwiftSpinner.show("Sending Email...")
                Auth.auth().sendPasswordReset(withEmail: email) { error in
                    if error != nil {
                        ModalService.showSuccess(title: "Sorry", message: (error?.localizedDescription)!)
                    }else{
                        ModalService.showSuccess(title: "Sent", message: "Check your inbox to reset your password.")
                    }
                        //SwiftSpinner.hide()
                }
            }.catch{ (error) in
            }.always {
            }
    }
    
     @IBAction func loginAction(_ sender: UIButton) -> Void {
        let email: String = emailText.text!
        let password: String = passwordText.text!

        if(!ValidityService.isValidEmail(email)){
            ModalService.showError(title: "Error", message: "Invalid email.")
        }
        else{
            spinner.isHidden = false
            spinner.startAnimating()
            Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                //If error, display message
                if error != nil {
                    self.spinner.isHidden = true
                    self.spinner.stopAnimating()
                    ModalService.showError(title: "Error", message: (error?.localizedDescription)!)
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
                                ModalService.showError(title: "Error", message: error.localizedDescription)
                            }
                        })
                        ModalService.showError(title: "Error", message: "Could not find profile.")
                        
                    }.always{
                        self.spinner.isHidden = true
                        self.spinner.stopAnimating()
                }
            })
        }
    }
    
    func goToHome() -> Void {
        if let nav = self.navigationController {
            var stack: [UIViewController] = nav.viewControllers
            stack.remove(at: 0)
            let homeTabBarController = storyBoard.instantiateViewController(withIdentifier: "HomeTabBarController") as! HomeTabBarController
            nav.pushViewController(homeTabBarController, animated: true)
            nav.setViewControllers([homeTabBarController], animated: true)
        }
    }
}
