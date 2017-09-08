import Foundation
import PromiseKit
import SCLAlertView
import Toaster
import UIKit

//https://github.com/vikmeup/SCLAlertView-Swift

class ModalService  {
    static func showError(title: String, message: String) -> Void {
        SCLAlertView().showError(title, subTitle: message)
    }
    
    static func showSuccess(title: String, message: String) -> Void {
        SCLAlertView().showSuccess(title, subTitle: message)
    }
    
    static func showWarning(title: String, message: String) -> Void {
        SCLAlertView().showWarning(title, subTitle: message)
    }
    
    static func showEdit(title: String, message: String) -> Void {
        SCLAlertView().showEdit(title, subTitle: message)
    }
    
    static func showInfo(title: String, message: String) -> Void {
        SCLAlertView().showInfo(title, subTitle: message)
    }
    
    static func showConfirm(title: String, message: String, confirmText: String, cancelText: String) -> Promise<Void> {
        return Promise{ fulfill, reject in
            
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            
            let alertView: SCLAlertView = SCLAlertView(appearance: appearance)
            
            alertView.addButton(confirmText){
                fulfill()
            }
            
            alertView.addButton(cancelText){
                reject(MyError.SomeError())
            }
            
            alertView.showWarning(title, subTitle: message)

        }
    }
}

public enum MyError : Error {
    case SomeError()
}

