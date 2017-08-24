import Material
import Firebase
import FirebaseDatabase
import Material
import SwiftSpinner
import UIKit

class SignupViewController: UIViewController {
    
    @IBOutlet weak var emailText: TextField!
    @IBOutlet weak var passwordText: TextField!
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
    
    func signup() -> Void {
        let email: String = emailText.text!
        let password: String = passwordText.text!
        
        if(!ValidityService.isValidEmail(email)){
            ModalService.displayAlert(title: "Error", message: "Invalid email", vc: self)
        }
        else{
            SwiftSpinner.show("Signing up...")
            Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                /* If error, display message. */
                if error != nil {
                    SwiftSpinner.hide()
                    ModalService.displayAlert(title: "Error", message: (error?.localizedDescription)!, vc: self)
                    return
                }
                
                //TODO: Determine why navigation controller is empty.
                if let nav = self.navigationController {
                    var stack: [UIViewController] = nav.viewControllers
                    stack.remove(at: 0)
                    stack.remove(at: 0)
                    nav.setViewControllers(stack, animated: true)
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    let homeTabBarController = storyBoard.instantiateViewController(withIdentifier: "HomeTabBarController") as! HomeTabBarController
                    nav.pushViewController(homeTabBarController, animated: true)
                }
                
                
                SwiftSpinner.hide()
            })
        }
    }
    
}

