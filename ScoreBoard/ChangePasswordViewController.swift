import FirebaseAuth
import Material
import UIKit

class ChangePasswordViewController : UIViewController {
    @IBOutlet weak var newPassword: TextField!
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
        saveBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(updatePassword)))
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
                ModalService.showError(title: "Sorry", message: error.localizedDescription)
            }.always{
                self.spinner.stopAnimating()
                self.spinner.isHidden = true
        }
    }
    
    func initUI() -> Void {
        hideKeyboardWhenTappedAround()
    }
    
    @objc func updatePassword() -> Void {
        let password: String = newPassword.text!
        
        if let currentUser = Auth.auth().currentUser {
            currentUser.updatePassword(to: password){ (error) in
                if let _ = error {
                    ModalService.showError(title: "Sorry", message: error!.localizedDescription)
                }else{
                    ModalService.showSuccess(title: "Success", message: "Password updated.")
                }
            }
        }else{
            ModalService.showError(title: "Error", message: "Could not update password, try again later.")
        }
    }
}


