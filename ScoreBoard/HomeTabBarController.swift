import UIKit

class HomeTabBarController : UITabBarController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Keep FCM up to date.
//        if(SessionManager.isLoggedIn()){
//            MyFirebaseRef.updateUserFCMToken(userId: SessionManager.getUserId()).always {}
//        }
    }
}
