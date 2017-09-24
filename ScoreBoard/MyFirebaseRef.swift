import Firebase
import PromiseKit

class MyFirebaseRef {
    
    private class var ref: DatabaseReference {
        return Database.database().reference()
    }
    
    private class var notificationService: NotificationService{
        return NotificationService()
    }
    
    private struct Table {
        static let Games: String = "Games"
        static let Users: String = "Users"
    }
    
    private class var storageRef: StorageReference {
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()
        // Create a storage reference from our storage service
        return storage.reference()
    }
    
//      ____
//     / ___|   __ _   _ __ ___     ___   ___
//    | |  _   / _` | | '_ ` _ \   / _ \ / __|
//    | |_| | | (_| | | | | | | | |  __/ \__ \
//     \____|  \__,_| |_| |_| |_|  \___| |___/
    
    //Returns an array of all games and their number of bets
    class func getGames() -> Promise<[Game]>{
        return Promise { fulfill, reject in
            ref.child(Table.Games).observeSingleEvent(of: .value, with: { (gameSnapshots) in
                var games: [Game] = []
                gameSnapshots.children.allObjects.forEach({ (gameSnapshot) in
                    games.append(extractGameData(gameSnapshot: gameSnapshot as! DataSnapshot))
                })
                //Return games
                fulfill(games)
            })
        }
    }
    
    //Returns a single game and the number of bets.
    class func getGame(gameId: String) -> Promise<Game>{
        return Promise { fulfill, reject in
            ref.child(Table.Games).child(gameId).observeSingleEvent(of: .value, with: { (gameSnapshot) in
                fulfill(extractGameData(gameSnapshot: gameSnapshot))
            })
        }
    }
    
    //Converts a dataSnapshot to a tuple of the game and the number of bets.
    private class func extractGameData(gameSnapshot: DataSnapshot) -> Game {
        let value = gameSnapshot.value as! [String:Any]
        let game: Game = Game()
        
        game.id = value["id"] as! String
        game.timeZoneOffSet = value["timeZoneOffSet"] as! Int
        game.postDateTime = ConversionService.convertStringToDate(value["postDateTime"] as! String)
        game.awayTeamId = value["awayTeamId"] as! Int
        game.homeTeamId = value["homeTeamId"] as! Int
        game.startDateTime = ConversionService.convertStringToDate(value["startDateTime"] as! String)
        game.activeCode = value["activeCode"] as! Int
        
        let betSnapshots = value["bets"] as? [String:Any]
        
        //If this game has bets currently...
        if let _ = betSnapshots {
            
            for betSnapshot in betSnapshots! {
                let betSnapshot = betSnapshot.value as! [String:Any]
                let bet: Bet = Bet()
                bet.id = betSnapshot["id"] as! String
                bet.postDateTime = ConversionService.convertStringToDate(betSnapshot["postDateTime"] as! String)
                bet.timeZoneOffSet = value["timeZoneOffSet"] as! Int
                bet.userId = betSnapshot["userId"] as! String
                bet.awayDigit = betSnapshot["awayDigit"] as! Int
                bet.homeDigit = betSnapshot["homeDigit"] as! Int
                
                game.bets.append(bet)
            }
            
            return (game)

        }
        
        return (game)
    }

//     ____           _
//    | __ )    ___  | |_   ___
//    |  _ \   / _ \ | __| / __|
//    | |_) | |  __/ | |_  \__ \
//    |____/   \___|  \__| |___/
    
    //Returns an array of all bets for a game.
    class func getBets(gameId: String) -> Promise<[Bet]>{
        return Promise { fulfill, reject in
            ref.child(Table.Games).child(gameId).child("bets").observeSingleEvent(of: .value, with: { (betSnapshots) in
                var bets: [Bet] = []
                betSnapshots.children.allObjects.forEach({ (betSnapshot) in
                    bets.append(extractBetData(betSnapshot: betSnapshot as! DataSnapshot))
                })
                //Return bets
                fulfill(bets)
            })
        }
    }
    
    //Returns a single bet.
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
        return bet
    }
    
    //Returns id of new user after insertion.
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
    
    //Returns user that matches facebook uid, (may return null).
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
    
    //Params: ID | Returns: User
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
        user.cash = value["cash"] as? Double
        user.userName = value["userName"] as? String
        user.email = value["email"] as? String
        user.imageDownloadUrl = value["imageDownloadUrl"] as? String
        return user
    }
    
    //Returns id of new user after insertion.
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
                "cash"              : 25.00,
                "imageDownloadUrl"  : "https://web.usask.ca/images/profile.jpg", //upload own "unwknown" image url.
                "postDateTime"      : ConversionService.convertDateToFirebaseString(now),
                "timeZoneOffSet"    : now.getTimeZoneOffset()
            ]
            
            //Subscribe to all topics by default.
            NotificationService.subscribeToTopic(Topics.Games.NewGame)
            
            newUserRef.setValue(newUserData)
            fulfill(newUserRef.key)
        }
    }
    
    //Remove a user from authentication, storage, and database.
    class func deleteUser(userId: String) -> Promise<Void> {
        //TODO: Delete all bets when a user deletes their account.
        return Promise { fulfill, reject in
            Auth.auth().currentUser?.delete(completion: { (err) in
                if err != nil {
                    reject(err!)
                }else{
                    //Remove user information from database.
                    ref.child(Table.Users).child(userId).setValue(nil)
                    //Remove user image from storage.
                    storageRef.child("Images/Users/" + userId).delete { error in
                        if let error = error {
                            print(error.localizedDescription)
                            //Most likely, the user never uploaded an image.
                        }
                        fulfill()
                    }
                }
            })
        }
    }
    
    class func updateProfilePicture(userId: String, image: UIImage) -> Promise<Void> {
        return Promise { fulfill, reject in
            var data: Data = Data()
            data = UIImageJPEGRepresentation(image, 0.8)!
            // set upload path
            let filePath = "Images/Users/" + userId
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            
            storageRef.child(filePath).putData(data, metadata: metaData){(metaData,error) in
                if let error = error {
                    reject(error)
                }else{
                    //Store download url.
                    let imageDownloadUrl = metaData!.downloadURL()!.absoluteString
                    //Store download url into database.
                    ref.child(Table.Users).child(userId).child("imageDownloadUrl").setValue(imageDownloadUrl)
                    fulfill()
                }
            }
        }
    }
    
    //Updates the current user's fcm token.
    class func updateUserFCMToken(userId: String) -> Promise<Void> {
        return Promise { fulfill, reject in
            let fcmToken = Messaging.messaging().fcmToken
            ref.child(Table.Users).child(userId).child("fcmToken").setValue(fcmToken)
            fulfill(())
        }
    }
    
    //Returns a user's fcm token for push notifications.
    class func getUserFCMToken(userId: String) -> Promise<String> {
        return Promise { fulfill, reject in
            ref.child(Table.Users).child(userId).child("fcmToken").observeSingleEvent(of: .value, with: { (fcmTokenSnapshot) in
                let data = fcmTokenSnapshot
                let value = data.value as! String
                fulfill(value)
            })
        }
    }

    class func addCashToUser(userId: String, cashToAdd: Double) -> Promise<Void> {
        return Promise { fulfill, reject in
            ref.child(Table.Users).child(userId).child("cash").runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
                if let currentCashAmount = currentData.value as? Double {
                    currentData.value = currentCashAmount + cashToAdd
                    return TransactionResult.success(withValue: currentData)
                }else{
                    return TransactionResult.success(withValue: currentData)
                }
            }, andCompletionBlock: {(error, completion, snap) in
                if completion {
                    fulfill()
                }else{
                    reject(MyError.SomeError())
                }
            })
        }
    }
    
    class func subtractCashToUser(userId: String, cashToSubtract: Double) -> Promise<Void> {
        return Promise { fulfill, reject in
            ref.child(Table.Users).child(userId).child("cash").runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
                if let currentCashAmount = currentData.value as? Double {
                    //Validate the user will not go in the negatives with this transaction.
                    if(currentCashAmount - cashToSubtract >= 0.00){
                        currentData.value = currentCashAmount - cashToSubtract
                        return TransactionResult.success(withValue: currentData)
                    }else{
                        return TransactionResult.abort()
                    }
                }else{
                    return TransactionResult.success(withValue: currentData)
                }
            }, andCompletionBlock: {(error, completion, snap) in
                if completion {
                    fulfill()
                }else{
                    reject(MyError.SomeError())
                }
            })
        }
    }
    
}


