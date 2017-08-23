import Foundation
import PopupDialog
import Toaster
import UIKit

class ModalService  {
    
    static func displayAlert(title: String, message: String, vc: UIViewController) -> Void {
        let popup = PopupDialog(title: title, message: message)
        popup.addButton(
            DefaultButton(title: "OK") {
            }
        )
        vc.present(popup, animated: true, completion: nil)
    }
    
    static func displayToast(text: String, backgroundColor: UIColor) -> Void {
        ToastView.appearance().backgroundColor = backgroundColor
        Toast(text: text).show()
    }
}
