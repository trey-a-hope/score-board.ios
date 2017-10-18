import Foundation
import PromiseKit
import Toaster
import UIKit

//https://github.com/vikmeup/SCLAlertView-Swift

class ModalService  {
    
    //Displays simple message to user.
    class func showAlert(title: String, message: String, vc: UIViewController) -> Void {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
    //Recieves OK/Cancel response from user and is sent back in a promise.
    class func showConfirm(title: String, message: String, vc: UIViewController) -> Promise<Void> {
        return Promise{ fulfill, reject in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {(action: UIAlertAction!) in
                reject(MyError.SomeError())
            }))
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action: UIAlertAction!) in
                fulfill(())
            }))
            vc.present(alert, animated: true, completion: nil)
        }
    }
    
    //Prompt user with text field to reset their password.
    class func showResetPassword(vc: UIViewController) -> Promise<String> {
        return Promise{ fulfill, reject in
            let alert = UIAlertController(title: "Reset Password?", message: "We will send an email with instructions on reseting your password.", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (_ textField: UITextField) -> Void in
                textField.placeholder = "Email"
                textField.isSecureTextEntry = true
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {(action: UIAlertAction!) in
                reject(MyError.SomeError())
            }))
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action: UIAlertAction!) in
                fulfill((alert.textFields?[0].text)!)
            }))
            vc.present(alert, animated: true, completion: nil)
        }
    }
}

public enum MyError : Error {
    case SomeError()
}

