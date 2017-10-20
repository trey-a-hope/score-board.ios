import UIKit
import Firebase
import UserNotifications

//https://makeappicon.com/ (for icons)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    let userDefaults = UserDefaults.standard
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()

        if #available(iOS 10.0, *) {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        
        //Tab Bar
        UITabBar.appearance().barTintColor = Constants.primaryColor
        UITabBar.appearance().tintColor = .white
        //Nav Bar
        UINavigationBar.appearance().barTintColor = Constants.primaryColor
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        //Status Bar
        UIApplication.shared.statusBarStyle = .lightContent
        UIApplication.shared.statusBarView?.backgroundColor = Constants.primaryColorDark
        
        //Log user out of Auth if id and role not set
        if userDefaults.object(forKey: "id") == nil {
            SessionManager.signOut()
        }
        
        return true
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([UNNotificationPresentationOptions.alert,UNNotificationPresentationOptions.sound,UNNotificationPresentationOptions.badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive: UNNotificationResponse, withCompletionHandler: @escaping ()->()) {
        withCompletionHandler()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        let remoteMessage = userInfo
        print("Forground : remoteMessage : \(remoteMessage)")
        Messaging.messaging().appDidReceiveMessage(remoteMessage)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        let remoteMessage = userInfo
        print("Background : remoteMessage : \(remoteMessage)")
        Messaging.messaging().appDidReceiveMessage(remoteMessage)
        
        completionHandler(.newData)
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        //The fcmToken is updated in the HomeTabBarController to ensure it happens only for logged in users.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().setAPNSToken(deviceToken, type: MessagingAPNSTokenType.sandbox)
        Messaging.messaging().setAPNSToken(deviceToken, type: MessagingAPNSTokenType.prod)
    }
}

extension AppDelegate : MessagingDelegate {
    func application(received remoteMessage: MessagingRemoteMessage) {
        print("applicationReceivedRemoteMessage ")
        print(remoteMessage.appData)
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("applicationDidReceiveRemoteMessage ")
        print("Received data message: \(remoteMessage.appData)")
    }
}
