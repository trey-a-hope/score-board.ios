import Firebase
import FirebaseDatabase
import Foundation
import UIKit

class SessionManager {
    private class var defaults: UserDefaults {
        return UserDefaults.standard
    }
    
    class func setUserId(_ id: String) -> Void {
        defaults.set(id, forKey: "id")
    }
    
    class func getUserId() -> String {
        return defaults.string(forKey: "id")!
    }
    
    class func signOut() -> Void {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            //print ("Successfully Logged Out")
        } catch let signOutError as NSError {
            //print ("Error signing out: %@", signOutError)
        }
    }
    
    class func isLoggedIn() -> Bool {
        let firebaseAuth = Auth.auth()
        return firebaseAuth.currentUser != nil
    }
}
