//import UserNotifications
//import Firebase
//import FirebaseInstanceID
//import FirebaseMessaging
//
////http://pushtry.com/
//
//@UIApplicationMain
//class AppDelegate: UIResponder, UIApplicationDelegate {
//    
//    var window: UIWindow?
//    let gcmMessageIDKey = "gcm.message_id"
//    let userDefaults = UserDefaults.standard
//    
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        /* Prepare Firebase */
//        FirebaseApp.configure()
//        
//        if #available(iOS 10.0, *) {
//            // For iOS 10 display notification (sent via APNS)
//            UNUserNotificationCenter.current().delegate = self
//            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//            UNUserNotificationCenter.current().requestAuthorization(
//                options: authOptions,
//                completionHandler: {_, _ in })
//            // For iOS 10 data message (sent via FCM
//            Messaging.messaging().delegate = self
//        } else {
//            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//            application.registerUserNotificationSettings(settings)
//        }
//        
//        /* Log user out of Auth if id and role not set. */
//        if(userDefaults.object(forKey: "id") == nil){
//            SessionManager.signOut()
//        }
//        
//        //Tab Bar
//        UITabBar.appearance().barTintColor = Constants.primaryColor
//        UITabBar.appearance().tintColor = .white
//        //Nav Bar
//        UINavigationBar.appearance().barTintColor = Constants.primaryColor
//        UINavigationBar.appearance().tintColor = UIColor.white
//        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
//        //Status Bar
//        UIApplication.shared.statusBarStyle = .lightContent
//        
//        return true
//    }
//    
//    func applicationWillResignActive(application: UIApplication) {
//        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
//        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
//    }
//    
//    func applicationDidEnterBackground(application: UIApplication) {
//        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
//        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    }
//    
//    func applicationWillEnterForeground(application: UIApplication) {
//        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
//    }
//    
//    func applicationDidBecomeActive(application: UIApplication) {
//        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    }
//    
//    func applicationWillTerminate(application: UIApplication) {
//        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//    }
//    
//}
//
//// [START ios_10_message_handling]
//@available(iOS 10, *)
//extension AppDelegate : UNUserNotificationCenterDelegate {
//    
//    // Receive displayed notifications for iOS 10 devices.
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        let userInfo = notification.request.content.userInfo
//        
//        Messaging.messaging().appDidReceiveMessage(userInfo)
//        
//        // With swizzling disabled you must let Messaging know about the message, for Analytics
//        // Messaging.messaging().appDidReceiveMessage(userInfo)
//        // Print message ID.
//        if let messageID = userInfo[gcmMessageIDKey] {
//            print("Message ID: \(messageID)")
//        }
//        
//        // Print full message.
//        print(userInfo)
//        
//        
//        
//        // Change this to your preferred presentation option
//        completionHandler([])
//    }
//    
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                didReceive response: UNNotificationResponse,
//                                withCompletionHandler completionHandler: @escaping () -> Void) {
//        let userInfo = response.notification.request.content.userInfo
//        // Print message ID.
//        if let messageID = userInfo[gcmMessageIDKey] {
//            print("Message ID: \(messageID)")
//        }
//        
//        // Print full message.
//        print(userInfo)
//        
//        
//        completionHandler()
//    }
//    
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
//                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        // If you are receiving a notification message while your app is in the background,
//        // this callback will not be fired till the user taps on the notification launching the application.
//        // TODO: Handle data of notification
//        // With swizzling disabled you must let Messaging know about the message, for Analytics
//        // Messaging.messaging().appDidReceiveMessage(userInfo)
//        // Print message ID.
//        if let messageID = userInfo[gcmMessageIDKey] {
//            print("Message ID: \(messageID)")
//        }
//        
//        // Print full message.
//        print(userInfo)
//        
//        if application.applicationState == .inactive || application.applicationState == .background {
//        }
//        
//        completionHandler(UIBackgroundFetchResult.newData)
//    }
//    
//    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
//        print("Unable to register for remote notifications: \(error.localizedDescription)")
//    }
//    
//    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
//    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
//    // the FCM registration token.
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        print("APNs token retrieved: \(deviceToken)")
//        
//        // With swizzling disabled you must set the APNs token here.
//        // Messaging.messaging().apnsToken = deviceToken
//    }
//    
//    //For iOS10 use these methods and  pay attention how we can get userInfo
//    // Foreground push notifications handler
//    @available(iOS 10.0, *)
//    func userNotificationCenter(center: UNUserNotificationCenter, willPresentNotification notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
//        if let userInfo = notification.request.content.userInfo as? [String : AnyObject] {
//            // Getting user info
//        }
//        completionHandler(.badge)
//    }
//    
//    // Background and closed  push notifications handler
//    @available(iOS 10.0, *)
//    func userNotificationCenter(center: UNUserNotificationCenter, didReceiveNotificationResponse response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void)  {
//        if let userInfo = response.notification.request.content.userInfo as? [String : AnyObject] {
//            // Getting user info
//        }
//        completionHandler()
//    }
//    
//}
//// [END ios_10_message_handling]
//
//extension AppDelegate : MessagingDelegate {
//    func application(received remoteMessage: MessagingRemoteMessage) {
//        print("Received remoteMessage: " + String(describing: remoteMessage.appData))
//    }
//    
//    // [START refresh_token]
//    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
//        
////        if(SessionManager.isLoggedIn()){
////            MyFirebaseRef.updateUserFCMToken(userId: SessionManager.getUserId(), fcmToken: fcmToken)
////                .then{() -> Void in
////                    
////                }.catch{ (error) in
////                    
////                }.always{
////                    
////            }
////        }
//        
//        print("Firebase registration token: \(fcmToken)")
//    }
//    // [END refresh_token]
//    // [START ios_10_data_message]
//    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
//    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
//    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
//        print("Received data message: \(remoteMessage.appData)")
//    }
//    // [END ios_10_data_message]
//}
//
import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    let userDefaults = UserDefaults.standard
    
    fileprivate func UI() -> Void {
        //Tab Bar
        UITabBar.appearance().barTintColor = Constants.primaryColor
        UITabBar.appearance().tintColor = .white
        //Nav Bar
        UINavigationBar.appearance().barTintColor = Constants.primaryColor
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        //Status Bar
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()

        if #available(iOS 10.0, *) {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            // For iOS 10 data message (sent via FCM)
            Messaging.messaging().remoteMessageDelegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        Messaging.messaging().connect { (error) in
            if error != nil {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
        application.registerForRemoteNotifications()
        
        self.UI()
        
        /* Log user out of Auth if id and role not set. */
        if(userDefaults.object(forKey: "id") == nil){
            //SessionManager.signOut()
        }
        
        return true
    }
    
    //This method is hit when the app is in the foreground...
    //TODO: Display pop up when in foreground.
    //TODO: Display pop up when in background, but first get the data.
    func application(received remoteMessage: MessagingRemoteMessage) {
        print("applicationReceivedRemoteMessage ")
        print(remoteMessage.appData)
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([UNNotificationPresentationOptions.alert,UNNotificationPresentationOptions.sound,UNNotificationPresentationOptions.badge])
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        
        // Print full message.
        print(userInfo)
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // set firebase apns token
        InstanceID.instanceID().setAPNSToken(deviceToken as Data, type: InstanceIDAPNSTokenType.unknown)
    }

}
