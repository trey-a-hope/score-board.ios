import FirebaseAuth
import Material
import UIKit

class ChangeEmailViewController : UIViewController {
    @IBOutlet weak var currentEmail: UILabel!
    @IBOutlet weak var newEmail: TextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var saveBtn: FABButton!
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareFabButton()
        getUserInformation()
    }
    
    func prepareFabButton() -> Void {
        saveBtn = FABButton(image: Icon.check, tintColor: .white)
        saveBtn.pulseColor = .white
        saveBtn.backgroundColor = Color.orange.base
        saveBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(updateEmail)))
        view.layout(saveBtn)
            .width(65)
            .height(65)
            .bottomRight(bottom: 35, right: 35)
    }
    
    func getUserInformation() -> Void {
        spinner.startAnimating()
        MyFSRef.getUserById(id: SessionManager.getUserId())
            .then{ (user) -> Void in
                self.user = user
                self.initUI()
            }.catch{ (error) in
                ModalService.showAlert(title: "Error", message: error.localizedDescription, vc: self)
            }.always{
                self.spinner.stopAnimating()
                self.spinner.isHidden = true
        }
    }
    
    func initUI() -> Void {
        hideKeyboardWhenTappedAround()
        //Set current email.
        currentEmail.text = user.email
//        newEmail.attributedPlaceholder = NSAttributedString(string: "newemail@domain.com", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
    }
    
    @objc func updateEmail() -> Void {
        let email: String = newEmail.text!
        if ValidityService.isValidEmail(email) {
            if email == currentEmail.text {
                ModalService.showAlert(title: "Sorry", message: "Email must be different from current email.", vc: self)
            }else{
                let currentUser = Auth.auth().currentUser
                //Update email user uses for auth purposes
                currentUser?.updateEmail(to: email) { error in
                    if let error = error {
                        ModalService.showAlert(title: "Sorry", message: error.localizedDescription, vc: self)
                    } else {
                        //Update email in firestore
                        MyFSRef.updateUserEmail(userId: self.user.id, email: email)
                            .then{ () -> Void in
                            }.always{
                                ModalService.showAlert(title: "Email Updated", message: "", vc: self)
                            }
                    }
                }
            }
        }else{
            ModalService.showAlert(title: "Sorry", message: "Invalid email.", vc: self)
        }
    }
}

