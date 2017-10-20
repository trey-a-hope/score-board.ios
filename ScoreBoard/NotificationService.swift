import Alamofire
import Foundation
import FirebaseMessaging
import PromiseKit

//TODO: but you still need to add "remote-notification" to the list of your supported UIBackgroundModes in your Info.plist.
class NotificationService {
    
    private class var endpoint: String{
        return "https://fcm.googleapis.com/fcm/send"
    }
    
    private class var serverKey: String {
        return "AAAAfHME-_0:APA91bH6DQ1SPpYZrmOOaH4SM7B9tpriXKxAq6Si9u9KMVTgU1GE3sazWp-AUketSUCiKlRtu76EIo3XjtG1lXzY2P59Th7X0N-cbi3Q2E9EQzyIuQhY2LXuIxCSs3NXZgi93P7yYykl"
    }
    
    private class func sendNotification( _ to: String, _ body: String, _ title: String) -> Promise<Void> {
        return Promise{ fulfill, reject in
            let headers: HTTPHeaders = [
                "Authorization": "key=" + serverKey,
                "Content-Type": "application/json"
            ]
            
            let parameters: Parameters = [
                "to": to,
                "priority" : "high",
                "notification": [
                    "title" : title,
                    "body": body
                ],
                "content_available": true
            ]
            
            //print("sendNotification: " + String(describing: parameters))
            Alamofire.request(endpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                //.validate()
                .responseString{ response in
                    
                    if response.error != nil  {
                        reject(response.error!)
                    }
                    
                    //print(JSONSerializer.toJson(response))
                    fulfill(())
            }
        }
    }
    
    class func sendNotificationToGroup(_ group: String, _ body: String, _ title: String) -> Promise<Void> {
        return sendNotification("/topics/" + group, body, title)
    }
    
    class func sendNotificationToUser(_ fcmToken: String, _ body: String, _ title: String) -> Promise<Void> {
        return sendNotification(fcmToken, body, title)
    }
    
    class func subscribeToTopic(_ topic: String) -> Void {
        Messaging.messaging().subscribe(toTopic: "/topics/" + topic)
    }
    
    class func unsubscribeFromTopic(_ topic: String) -> Void {
        Messaging.messaging().unsubscribe(fromTopic: "/topics/" + topic)
    }
    
}

/* Groups that a user can subscribe to. Topics must be exact between Web, iOS, and Android */
struct Topics {
    struct Games {
        static let NewGame: String = "NEW_GAME"
    }
}
