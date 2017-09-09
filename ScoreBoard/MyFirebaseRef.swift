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
    
//      ____
//     / ___|   __ _   _ __ ___     ___   ___
//    | |  _   / _` | | '_ ` _ \   / _ \ / __|
//    | |_| | | (_| | | | | | | | |  __/ \__ \
//     \____|  \__,_| |_| |_| |_|  \___| |___/
    
    /* Returns an array of all games and their number of bets */
    class func getGames() -> Promise<[(game: Game, betCount: Int)]>{
        return Promise { fulfill, reject in
            ref.child(Table.Games).observeSingleEvent(of: .value, with: { (gameSnapshots) in
                var games: [(game: Game, betCount: Int)] = []
                gameSnapshots.children.allObjects.forEach({ (gameSnapshot) in
                    games.append(extractGameData(gameSnapshot: gameSnapshot as! DataSnapshot))
                })
                /* Return camps */
                fulfill(games)
            })
        }
    }
    
    /* Returns a single game and the number of bets. */
    class func getGame(gameId: String) -> Promise<(game: Game, betCount: Int)>{
        return Promise { fulfill, reject in
            ref.child(Table.Games).child(gameId).observeSingleEvent(of: .value, with: { (gameSnapshot) in
                fulfill(extractGameData(gameSnapshot: gameSnapshot))
            })
        }
    }
    
    //Converts a dataSnapshot to a tuple of the game and the number of bets.
    private class func extractGameData(gameSnapshot: DataSnapshot) -> (game: Game, betCount: Int) {
        let value = gameSnapshot.value as! [String:Any]
        let game: Game = Game()
        game.id = value["id"] as! String
        game.timeZoneOffSet = value["timeZoneOffSet"] as! Int
        game.postDateTime = ConversionService.convertStringToDate(value["postDateTime"] as! String)
        game.awayTeamId = value["awayTeamId"] as! Int
        game.homeTeamId = value["homeTeamId"] as! Int
        game.startDateTime = ConversionService.convertStringToDate(value["startDateTime"] as! String)
        game.activeCode = value["activeCode"] as! Int
        let bets = value["bets"] as? [String:Any]
        var betCount: Int = 0
        
        if let _ = bets {
            betCount = bets!.count
        }
        
        return (game, betCount)
    }
    
//     ____           _
//    | __ )    ___  | |_   ___
//    |  _ \   / _ \ | __| / __|
//    | |_) | |  __/ | |_  \__ \
//    |____/   \___|  \__| |___/
    
    /* Returns an array of all bets for a game. */
    class func getBets(gameId: String) -> Promise<[Bet]>{
        return Promise { fulfill, reject in
            ref.child(Table.Games).child(gameId).child("bets").observeSingleEvent(of: .value, with: { (betSnapshots) in
                var bets: [Bet] = []
                betSnapshots.children.allObjects.forEach({ (betSnapshot) in
                    bets.append(extractBetData(betSnapshot: betSnapshot as! DataSnapshot))
                })
                /* Return bets */
                fulfill(bets)
            })
        }
    }
    
    /* Returns a single bet. */
    class func getBet(gameId: String, betId: String) -> Promise<Bet>{
        return Promise { fulfill, reject in
            ref.child(Table.Games).child(gameId).child("bets").child(betId).observeSingleEvent(of: .value, with: { (betSnapshot) in
                fulfill(extractBetData(betSnapshot: betSnapshot))
            })
        }
    }
    
    //Converts a dataSnapshot to a Bet object.
    private class func extractBetData(betSnapshot: DataSnapshot) -> Bet {
        let value = betSnapshot.value as! [String:Any]
        let bet: Bet = Bet()
        bet.id = value["id"] as! String
        bet.timeZoneOffSet = value["timeZoneOffSet"] as! Int
        bet.postDateTime = ConversionService.convertStringToDate(value["postDateTime"] as! String)
        bet.awayDigit = value["awayDigit"] as! Int
        bet.homeDigit = value["homeDigit"] as! Int
        bet.userId = value["userId"] as! String
        bet.userImageDownloadUrl = value["userImageDownloadUrl"] as! String
        bet.userName = value["userName"] as! String
        return bet
    }
    
    /* Returns id of new user after insertion. */
    class func createNewBet(gameId: String, bet: Bet) -> Promise<String> {
        return Promise{ fulfill, reject in
            let newBetRef: DatabaseReference = ref.child(Table.Games).child(gameId).child("bets").childByAutoId()
            let now: Date = Date()
            // Create bet data.
            let newBetData: [String : Any] = [
                "id"                    : newBetRef.key,
                "awayDigit"             : bet.awayDigit,
                "homeDigit"             : bet.homeDigit,
                "userId"                : bet.userId,
                "userImageDownloadUrl"  : bet.userImageDownloadUrl,
                "userName"              : bet.userName,
                "postDateTime"          : ConversionService.convertDateToFirebaseString(now),
                "timeZoneOffSet"        : now.getTimeZoneOffset()
            ]
            
            newBetRef.setValue(newBetData)
            fulfill(newBetRef.key)
        }
    }
    
//     _   _
//    | | | |  ___    ___   _ __   ___
//    | | | | / __|  / _ \ | '__| / __|
//    | |_| | \__ \ |  __/ | |    \__ \
//     \___/  |___/  \___| |_|    |___/
    
    /* Returns user that matches facebook uid, (may return null). */
    class func getUserByEmail(email: String) -> Promise<User>{
        return Promise{ fulfill, reject in
            ref.child(Table.Users).queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value, with: { (userSnapShots) in
                if(userSnapShots.exists()){
                    userSnapShots.children.allObjects.forEach({ (userSnapShot) in
                        fulfill(extractUserData(userSnapshot: userSnapShot as! DataSnapshot))
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
                fulfill(extractUserData(userSnapshot: userSnapShot))
            })
        }
    }
    
    //Converts a dataSnapshot to a user object.
    private class func extractUserData(userSnapshot: DataSnapshot) -> User {
        let value = userSnapshot.value as! [String:Any]
        let user: User = User()
        user.id = value["id"] as! String
        user.timeZoneOffSet = value["timeZoneOffSet"] as! Int
        user.postDateTime = ConversionService.convertStringToDate(value["postDateTime"] as! String)
        user.fcmToken = value["fcmToken"] as? String
        user.chips = value["chips"] as? Int
        user.userName = value["userName"] as? String
        user.email = value["email"] as? String
        user.imageDownloadUrl = value["imageDownloadUrl"] as? String
        return user
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


