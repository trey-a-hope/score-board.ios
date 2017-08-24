import Firebase
import PromiseKit

class MyFirebaseRef {
    
    private class var ref: DatabaseReference {
        return Database.database().reference()
    }
    
//    private class var notificationService: NotificationService{
//        return NotificationService()
//    }
    
    private struct Table {
        static let Games: String = "Games"
        static let Users: String = "Users"
    }
    
    /* Returns an array of all games. */
    class func getGames() -> Promise<[Game]>{
        return Promise { fulfill, reject in
            ref.child(Table.Games).observeSingleEvent(of: .value, with: { (gameSnapshots) in
                var games: [Game] = []
                gameSnapshots.children.allObjects.forEach({ (gameSnapshot) in
                    let data = gameSnapshot as! DataSnapshot
                    let value = data.value as! [String:Any]
                    let game: Game = Game()
                    
                    game.id = value["id"] as! String
                    game.awayTeamId = value["awayTeamId"] as! Int
                    game.homeTeamId = value["homeTeamId"] as! Int
                    game.startDateTime = ConversionService.convertStringToDate(value["startDateTime"] as! String)
                    game.timeZoneOffSet = value["timeZoneOffSet"] as! Int
                    game.postDateTime = ConversionService.convertStringToDate(value["postDateTime"] as! String)
                    games.append(game)
                })
                /* Return camps */
                fulfill(games)
            })
        }
    }
    
    /* Returns a single game. */
    class func getGame(gameId: String) -> Promise<Game>{
        return Promise { fulfill, reject in
            ref.child(Table.Games).child(gameId).observeSingleEvent(of: .value, with: { (gameSnapshot) in
                let value = gameSnapshot.value as! [String:Any]
                let game: Game = Game()
                
                game.id = value["id"] as! String
                game.awayTeamId = value["awayTeamId"] as! Int
                game.homeTeamId = value["homeTeamId"] as! Int
                game.startDateTime = ConversionService.convertStringToDate(value["startDateTime"] as! String)
                game.timeZoneOffSet = value["timeZoneOffSet"] as! Int
                game.postDateTime = ConversionService.convertStringToDate(value["postDateTime"] as! String)
                
                fulfill(game)
            })
        }
    }
    
    /* Returns user that matches facebook uid, (may return null). */
    class func getUserByEmail(email: String) -> Promise<User>{
        return Promise{ fulfill, reject in
            ref.child(Table.Users).queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value, with: { (userSnapShots) in
                if(userSnapShots.exists()){
                    userSnapShots.children.allObjects.forEach({ (userSnapShot) in
                        let data = userSnapShot as! DataSnapshot
                        let value = data.value as! [String:Any]
                        let user: User = User()
                        user.id = value["id"] as! String
                        user.userName = value["userName"] as! String
                        user.email = value["email"] as! String
                        user.timeZoneOffSet = value["timeZoneOffSet"] as! Int
                        user.postDateTime = ConversionService.convertStringToDate(value["postDateTime"] as! String)
                        fulfill(user)
                    })
                }else{
                    reject(NSError(domain:"", code: 505, userInfo:nil))
                }
            })
        }
    }
    
    /* Params: ID | Returns: User */
    class func getUserByID(id: String) -> Promise<User>{
        return Promise{ fulfill, reject in
            ref.child(Table.Users).child(id).observeSingleEvent(of: .value, with: { (userSnapShot) in
                let data = userSnapShot
                let value = data.value as! [String:Any]
                let user: User = User()
                user.id = value["id"] as! String
                //user.fcmToken = value["fcmToken"] as! String
                user.chips = value["chips"] as! Int
                user.userName = value["userName"] as! String
                user.email = value["email"] as! String
                user.timeZoneOffSet = value["timeZoneOffSet"] as! Int
                user.postDateTime = ConversionService.convertStringToDate(value["postDateTime"] as! String)
                fulfill(user)
            })
        }
    }
    
    /* Returns id of new user after insertion. */
    class func createNewUser(_ user: User) -> Promise<String> {
        return Promise{ fulfill, reject in
            let newUserRef: DatabaseReference = ref.child(Table.Users).childByAutoId()
            let now: Date = Date()
            // Create user data.
            let newUserData: [String : Any] = [
                "id"                : newUserRef.key,
                "uid"               : user.uid,
                "userName"          : user.userName,
                "email"             : user.email,
                "chips"             : 50,
                "postDateTime"      : ConversionService.convertDateToFirebaseString(now),
                "timeZoneOffSet"    : now.getTimeZoneOffset()
            ]
            
            newUserRef.setValue(newUserData)
            fulfill(newUserRef.key)
        }
    }
    
    /* Updates the current user's fcm token. */
    class func updateUserFCMToken(userId: String) -> Promise<Void> {
        return Promise { fulfill, reject in
            let token = Messaging.messaging().fcmToken
            ref.child(Table.Users).child(userId).child("fcmToken").setValue(token)
            print("updateUserFCMToken: " + String(describing: token))
            fulfill(())
        }
    }
    
    /* Returns a user's fcm token for push notifications. */
    class func getUserFCMToken(userId: String) -> Promise<String> {
        return Promise { fulfill, reject in
            ref.child(Table.Users).child(userId).child("fcmToken").observeSingleEvent(of: .value, with: { (fcmTokenSnapshot) in
                let data = fcmTokenSnapshot
                let value = data.value as! String
                print("getUserFCMToken: " + String(describing: value))
                fulfill(value)
            })
        }
    }

    
}


