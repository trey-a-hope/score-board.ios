import Material
import Firebase
import Material
import UIKit

class SignupViewController: UIViewController {
    @IBOutlet weak var emailText: TextField!
    @IBOutlet weak var passwordText: TextField!
    @IBOutlet weak var usernameText: TextField!
    @IBOutlet weak var signupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    func initUI() -> Void {
        self.hideKeyboardWhenTappedAround()
        
        signupButton.addTarget(
            self,
            action: #selector(SignupViewController.signup),
            for: UIControlEvents.touchUpInside
        )
    }
    
    @objc func signup() -> Void {
        let email: String = emailText.text!
        let password: String = passwordText.text!
        let username: String = usernameText.text!
        
        if !ValidityService.isValidEmail(email) {
            ModalService.showAlert(title: "Invalid Email", message: "Please fix", vc: self)
        }
        else{
            Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                //If error, display message.
                if error != nil {
                    ModalService.showAlert(title: "Error", message: (error?.localizedDescription)!, vc: self)
                    return
                }
                
                //Prepare user data.
                let newUser: User = User()
                newUser.email = email
                newUser.userName = username
                newUser.uid = Auth.auth().currentUser?.uid
                
                MyFSRef.createUser(user: newUser)
                    .then{ (newUserId) -> Void in
                        SessionManager.setUserId(newUserId)
                        //Return to login screen.
                        _ = self.navigationController?.popViewController(animated: true)
                    }.catch{ (error) in
                        SessionManager.signOut()
                    }.always{
                        //SwiftSpinner.hide()
                }
            })
        }
    }
    
}

