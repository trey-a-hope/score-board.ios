import FirebaseAuth
import FirebaseDatabase
import Material
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
        
        if(ConnectionManager.isConnectedToInternet()){
            prepareFabButton()
            getUserInformation()
        }else{
            ModalService.showNoInternetConnection()
        }
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
        MyFirebaseRef.getUserByID(id: SessionManager.getUserId())
            .then{ (user) -> Void in
                self.user = user
                self.initUI()
            }.catch{ (error) in
                ModalService.showError(title: "Sorry", message: error.localizedDescription)
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
    
    func updateEmail() -> Void {
        let email: String = newEmail.text!
        if(ValidityService.isValidEmail(email)){
            if(email == currentEmail.text){
                ModalService.showError(title: "Sorry", message: "Email must be different from current email.")
            }else{
                let currentUser = Auth.auth().currentUser
                currentUser?.updateEmail(to: email) { error in
                    if let error = error {
                        ModalService.showError(title: "Sorry", message: error.localizedDescription)
                    } else {
                        // Fire Auth Email updated.
                        let userRef: DatabaseReference! = Database.database().reference().child("Users").child(self.user.id)
                        userRef.updateChildValues(["email" : email])
                        // Fire Database Email updated.
                        ModalService.showSuccess(title: "Success", message: "Email updated.")
                    }
                }
            }
        }else{
            ModalService.showError(title: "Sorry", message: "Invalid email.")
        }
    }
}

