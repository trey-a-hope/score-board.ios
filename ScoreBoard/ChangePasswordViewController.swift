import FirebaseAuth
import Material
import UIKit

class ChangePasswordViewController : UIViewController {
    @IBOutlet private weak var newPassword  : TextField!
    @IBOutlet private weak var spinner      : UIActivityIndicatorView!
    
    private var saveBtn: FABButton!
    private var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUserInformation()
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
    
    /// Initialize all components needed for UI.
    /// - returns: Void
    /// - throws: No error.
    private func initUI() -> Void {
        hideKeyboardWhenTappedAround()
        
        saveBtn = FABButton(image: Icon.check, tintColor: .white)
        saveBtn.pulseColor = .white
        saveBtn.backgroundColor = Color.orange.base
        saveBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(updatePassword)))
        view.layout(saveBtn)
            .width(65)
            .height(65)
            .bottomRight(bottom: 35, right: 35)
    }
    
    @objc func updatePassword() -> Void {
        let password: String = newPassword.text!
        
        if let currentUser = Auth.auth().currentUser {
            currentUser.updatePassword(to: password){ (error) in
                if let _ = error {
                    ModalService.showAlert(title: "Error", message: error!.localizedDescription, vc: self)
                }else{
                    ModalService.showAlert(title: "Password Updated", message: "", vc: self)
                }
            }
        }else{
            ModalService.showAlert(title: "Sorry", message: "Could not update password, try again later.", vc: self)
        }
    }
}


