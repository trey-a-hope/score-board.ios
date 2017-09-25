import UIKit

class HomeTabBarController : UITabBarController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.edgesForExtendedLayout = []
        
        //Keep FCM up to date.
        if(SessionManager.isLoggedIn()){
            //Ensure the user's data is still there before updating the fcm token.
            MyFirebaseRef.userExists(id: SessionManager.getUserId())
                .then{ (exists) -> Void in
                    if(exists){
                        MyFirebaseRef.updateUserFCMToken(userId: SessionManager.getUserId()).always {}
                    }
                }.always{}
        }
    }
}
