import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import PromiseKit

class MyFSRef {
    private static var db: Firestore { return Firestore.firestore() }
    
    private static var notificationService: NotificationService { return NotificationService() }
    
    private static var storageRef: StorageReference { return Storage.storage().reference() }
    
    /// Updates a property for all objects in a table. Example, updating an "email" property for all users.
    /// - parameter table - String      : Name of table.
    /// - parameter property - String   : Property to be updated.
    /// - parameter value - String      : Value to be assigned to said property.
    /// - returns: Void
    /// - throws: No error.
    public static func updatePropertiesOnTable(table: String, property: String, value: String) -> Promise<Void> {
        return Promise{ fulfill, reject in
            db.collection(table).getDocuments(completion: { (col, err) in
                for doc in (col?.documents)! {
                    let data: [String:Any]  = doc.data()
                    let id  : String        = data["id"] as! String
                    db.collection(table).document(id).updateData([
                        property: value
                        ])
                }
                fulfill(())
            })
        }
    }
    
    /// Removes a property from all objects in a table. Example, removing an "email" property from all users.
    /// - parameter table - String      : Name of table.
    /// - parameter property - String   : Property to be removed.
    /// - returns: Void
    /// - throws: No error.
    public static func deletePropertyFromObjects(table: String, property: String) -> Promise<Void> {
        return Promise{ fulfill, reject in
            db.collection(table).getDocuments(completion: { (col, err) in
                for doc in (col?.documents)! {
                    let data: [String:Any]  = doc.data()
                    let id  : String        = data["id"] as! String
                    db.collection(table).document(id).updateData([
                        property: FieldValue.delete()
                        ])
                }
                fulfill(())
            })
        }
    }
    
    //     ____           _
    //    | __ )    ___  | |_   ___
    //    |  _ \   / _ \ | __| / __|
    //    | |_) | |  __/ | |_  \__ \
    //    |____/   \___|  \__| |___/
    
    /// Return all bets for a game.
    /// - parameter gameId - String : Id of the game.
    /// - returns: [Bet]            : All bets for that game.
    /// - throws: No error.
    static func getBetsForGame(gameId: String) -> Promise<[Bet]> {
        return Promise{ fulfill, reject in
            db.collection("Bets").whereField("gameId", isEqualTo: gameId).getDocuments(completion: { (collection, error) in
                if let error = error { reject(error) }
                
                var bets: [Bet] = [Bet]()
                for document in (collection?.documents)! {
                    bets.append(extractBetData(betSnapshot: document))
                }
                
                fulfill(bets)
            })
        }
    }
    
    /// Return all bets for a user.
    /// - parameter userId - String : Id of the user.
    /// - returns: [Bet]            : All bets for that user.
    /// - throws: No error.
    static func getBetsForUser(userId: String) -> Promise<[Bet]> {
        return Promise{ fulfill, reject in
            db.collection("Bets").whereField("userId", isEqualTo: userId).getDocuments(completion: { (collection, error) in
                if let error = error { reject(error) }
                
                var bets: [Bet] = [Bet]()
                for document in (collection?.documents)! {
                    bets.append(extractBetData(betSnapshot: document))
                }
                
                fulfill(bets)
            })
        }
    }
    
    /// Create a new bet for a game.
    /// - parameter bet - Bet : Bet to be created.
    /// - returns: String - Id of new bet.
    /// - throws: No error.
    static func createBet(bet: Bet) -> Promise<String> {
        return Promise{ fulfill, reject in
            
            var ref: DocumentReference? = nil
            
            let data: [String : Any] = [
                "id"                    : "",
                "homeTeam"              : bet.homeTeam,
                "homeDigit"             : bet.homeDigit,
                "awayTeam"              : bet.awayTeam,
                "awayDigit"             : bet.awayDigit,
                "userId"                : bet.userId,
                "gameId"                : bet.gameId,
                "timestamp"             : String(describing: Date())
            ]
            
            //Add bet - I pray they come up with a better solution for referencing the ref id, this is tacky
            ref = db.collection("Bets").addDocument(data: data){err in
                if let err = err {
                    reject(err)
                    print("Error adding document: \(err)")
                } else {
                    //Update id of game
                    ref!.updateData([
                        "id": ref!.documentID
                    ]){err in
                        if let err = err {
                            reject(err)
                        }
                        print("Document added with ID: \(ref!.documentID)")
                        fulfill(ref!.documentID)
                    }
                }
            }
        }
    }
    
    //      ____
    //     / ___|   __ _   _ __ ___     ___   ___
    //    | |  _   / _` | | '_ ` _ \   / _ \ / __|
    //    | |_| | | (_| | | | | | | | |  __/ \__ \
    //     \____|  \__,_| |_| |_| |_|  \___| |___/
    

    
    /// Get a game by its id.
    /// - parameter gameId - String : Id of game.
    /// - returns: Game - Game to be fetched.
    /// - throws: No error.
    static func getGame(gameId: String) -> Promise<Game> {
        return Promise{ fulfill, reject in
            db.collection("Games").document(gameId).getDocument(completion: { (gameDoc, err) in
                if let err = err { reject(err) }
                fulfill(extractGameData(gameDoc: gameDoc!))
            })
        }
    }
    
    //RETURNS ALL GAMES : TODO: DELETE THIS!
    class func getAllGames() -> Promise<[Game]> {
        var games: [Game] = [Game]()
        return Promise{ fulfill, reject in
            db.collection("Games").getDocuments(completion: { (collection, err) in
                if let err = err { reject(err) }
                
                for gameDoc in (collection?.documents)! {
                    games.append(extractGameData(gameDoc: gameDoc))
                }
                
                fulfill(games)
            })
        }
    }
    
    class func getGamesByStatus(status: Int) -> Promise<[Game]> {
        var games: [Game] = [Game]()
        return Promise{ fulfill, reject in
            db.collection("Games").whereField("status", isEqualTo: status).getDocuments(completion: { (collection, err) in
                if let err = err { reject(err) }
                
                for gameDoc in (collection?.documents)! {
                    games.append(extractGameData(gameDoc: gameDoc))
                }
                
                fulfill(games)
            })
        }
    }
    
    //RETURNS ALL GAMES FOR A USER
    class func getGamesForUser(userId: String)-> Promise<[Game]> {
        var games: [Game] = [Game]()
        return Promise{ fulfill, reject in
            db.collection("Games").whereField("userId", isEqualTo: userId).getDocuments(completion: { (collection, err) in
                if let err = err { reject(err) }
                for gameDoc in (collection?.documents)! {
                    games.append(extractGameData(gameDoc: gameDoc))
                }
                fulfill(games)
            })
        }
    }
    
    //LINK A USER TO A GAME
    class func takeGame(gameId: String, potAmount: Double, betPrice: Double, userId: String) -> Promise<Void> {
        return Promise{ fulfill, reject in
            db.collection("Games").document(gameId).updateData([
                "userId"    : userId,
                "potAmount" : potAmount,
                "betPrice"  : betPrice
            ]){ err in
                if let err = err {
                    reject(err)
                } else {
                    fulfill(())
                }
            }
        }
    }
    
    //Update the score and active code
    class func updateGame(gameId: String, status: Int, homeTeamScore: Int, awayTeamScore: Int) -> Promise<Void> {
        return Promise{ fulfill, reject in
            db.collection("Games").document(gameId).updateData([
                "status"                : status,
                "homeTeamScore"         : homeTeamScore,
                "awayTeamScore"         : awayTeamScore
            ]){ err in
                if let err = err {
                    reject(err)
                } else {
                    fulfill(())
                }
            }
        }
    }
    
    //CREATE A NEW GAME
    class func createGame(game: Game) -> Promise<String> {
        return Promise{ fulfill, reject in
            var ref: DocumentReference? = nil
            
            let data: [String : Any] = [
                "id"                    : "",
                "status"                : 0,
                "homeTeam"              : game.homeTeam,
                "homeTeamScore"         : 0,
                "awayTeam"              : game.awayTeam,
                "awayTeamScore"         : 0,
                "starts"                : String(describing: game.starts!),
                "timestamp"             : String(describing: Date())
            ]
            
            ref = db.collection("Games").addDocument(data: data){err in
                if let err = err {
                    reject(err)
                    print("Error adding document: \(err)")
                } else {
                    //Update id of game
                    ref!.updateData([
                        "id": ref!.documentID
                    ]){err in
                        if let err = err {
                            reject(err)
                        }
                        print("Document added with ID: \(ref!.documentID)")
                        fulfill(ref!.documentID)
                    }
                }
            }
        }
    }
    
    //     _   _
    //    | | | |  ___    ___   _ __   ___
    //    | | | | / __|  / _ \ | '__| / __|
    //    | |_| | \__ \ |  __/ | |    \__ \
    //     \___/  |___/  \___| |_|    |___/
    
    
    //DELETE USER FROM AUTHENTICATION, DATABASE, AND STORAGE
    class func deleteUser(userId: String) -> Promise<Void> {
        //TODO: Delete all bets when a user deletes their account.
        return Promise { fulfill, reject in
            Auth.auth().currentUser?.delete(completion: { (err) in
                if err != nil {
                    reject(err!)
                }else{
                    db.collection("Users").document(userId).delete(){error in
                        if let error = error {
                            print("Error removing document: \(error)")
                        } else {
                            //Remove user image from storage.
                            storageRef.child("Images/Users/" + userId).delete { error in
                                if let error = error {
                                    print(error.localizedDescription)
                                    //Most likely, the user never uploaded an image.
                                }
                                fulfill(())
                            }
                        }
                    }
                }
            })
        }
    }
    
    //UPDATE USER EMAIL
    class func updateUserEmail(userId: String, email: String) -> Promise<Void> {
        return Promise { fulfill, reject in
            db.collection("Users").document(userId).updateData([
                "email" : email
            ]){error in
                if let error = error {
                    reject(error)
                }
                fulfill(())
            }
        }
    }
    
    /// Make this user become a follower of the user specified.
    /// - parameter myUserId - String       : Current user id.
    /// - parameter myFollowings - [String] : Array of userIds that the current user follows.
    /// - parameter theirUserId - String    : Recepient user id.
    /// - parameter myFollowings - [String] : Array of userIds that follow the recepient user.
    /// - returns: Void
    /// - throws: No error.
    static func followUser(myUserId: String, myFollowings: [String], theirUserId: String, theirFollowers: [String]) -> Promise<Void> {
        return Promise{ fulfill, reject in
            db.collection("Users").document(myUserId).updateData([
                "followings" : myFollowings
            ]){ err in
                if let err = err { reject(err) }
                db.collection("Users").document(theirUserId).updateData([
                    "followers" : theirFollowers
                ]){ err in
                    if let err = err { reject(err) }
                    else { fulfill(()) }
                }
            }
        }
    }
    
    /// Update a user's information from the edit profile page.
    /// - parameter user - User : User information.
    /// - returns: Void
    /// - throws: No error.
    static func updateUser(user: User) -> Promise<Void> {
        return Promise { fulfill, reject in
            db.collection("Users").document(user.id).updateData([
                "userName"      : user.userName,
                "phoneNumber"   : user.phoneNumber,
                "city"          : user.city,
                "stateId"       : user.stateId,
                "gender"        : user.gender
            ]){error in
                if let error = error {
                    reject(error)
                }
                fulfill(())
            }
        }
    }
    
    //UPDATE PROFILE PICTURE
    class func updateProfilePicture(userId: String, image: UIImage) -> Promise<Void> {
        return Promise { fulfill, reject in
            let data: Data = UIImageJPEGRepresentation(image, 0.8)!
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
                    db.collection("Users").document(userId).updateData([
                        "imageDownloadUrl": imageDownloadUrl
                    ]){error in
                        if let error = error {
                            reject(error)
                        }
                        fulfill(())
                    }
                }
            }
        }
    }
    
    //RETURNS USER THAT MATCHES ID
    class func getUserById(id: String) -> Promise<User> {
        return Promise{ fulfill, reject in
            db.collection("Users").document(id).getDocument(completion: { (document, error) in
                if let error = error { reject(error) }
                fulfill(extractUserData(userSnapshot: document!))
            })
        }
    }
    
    //RETURNS USER THAT MATCHES EMAIL
    class func getUserByEmail(email: String) -> Promise<User> {
        return Promise{ fulfill, reject in
            db.collection("Users").whereField("email", isEqualTo: email).getDocuments(completion: { (collection, error) in
                if let error = error { reject(error) }
                fulfill(extractUserData(userSnapshot: (collection?.documents[0])!))
            })
        }
    }
    
    //RETURNS A SPECIFIED AMOUNT OF USERS BY CATEGORY
    class func getTopUsers(category: String, numberOfUsers: Int) -> Promise<[User]> {
        return Promise { fulfill, reject in
            db.collection("Users").order(by: category).limit(to: numberOfUsers).getDocuments(completion: { (collection, error) in
                if let error = error { reject(error) }
                var users: [User] = [User]()
                for document in (collection?.documents)! {
                    users.append(extractUserData(userSnapshot: document))
                }
                
                fulfill(users.reversed())
            })
        }
    }
    
    //RETURN A SPECIFIED AMOUNT OF USERS BASED ON A SEARCH STRING
    class func getUsersFromSearch(category: String, search: String, numberOfUsers: Int) -> Promise<[User]> {
            return Promise { fulfill, reject in
                //            The character \uf8ff used in the query is a very high code point in the Unicode range (it is a Private Usage Area [PUA] code). Because it is after most regular characters in Unicode, the query matches all values that start with queryText.
                //            In this way, searching by "Fre" I could get the records having "Fred, Freddy, Frey" as value in "userName" property from the database.
                db.collection("Users").order(by: category).start(at: [search]).end(at: [search + "\u{f8ff}"]).limit(to: numberOfUsers).getDocuments(completion: { (collection, error) in
                    if let error = error { reject(error) }
                    
                    var users: [User] = [User]()
                    for document in (collection?.documents)! {
                        users.append(extractUserData(userSnapshot: document))
                    }
                    fulfill(users)
                    
                })
            }
        }
    
    //UPDATES THE CURRENT USER'S FCM TOKEN
    class func updateUserFCMToken(userId: String) -> Promise<Void> {
        return Promise { fulfill, reject in
            if let fcmToken = Messaging.messaging().fcmToken {
                db.collection("Users").document(userId).updateData([
                    "fcmToken": fcmToken
                ]){error in
                    if let error = error {
                        reject(error)
                    }
                    fulfill(())
                }
            }else{
                reject(MyError.SomeError())
            }
        }
    }
    
    //RETURNS A USER'S FCM TOKEN FOR PUSH NOTIFICATIONS
    class func getUserFCMToken(userId: String) -> Promise<String> {
        return Promise { fulfill, reject in
            db.collection("Users").document(userId).getDocument(completion: { (document, error) in
                let value = document!.data()
                
                if let fcmToken = value["fcmToken"] {
                    fulfill(fcmToken as! String )
                }else{
                    //reject()
                }
            })
        }
    }
    
    /// Updates a user's notifications.
    /// - parameter userId - String : Id of user.
    /// - parameter notifications - [String:Bool] : Array of notifications.
    /// - returns: Void
    /// - throws: No error.
    public static func updateNotifications(id: String, notifications: [String:Bool]) -> Promise<Void> {
        return Promise { fulfill, reject in
            
            db.collection("Users").document(id).updateData([
                "notifications" : notifications
            ]){ err in
                if let err = err {
                    reject(err)
                } else {
                    fulfill(())
                }
            }
        }
    }
    
    //CREATE A NEW USER
    class func createUser(user: User) -> Promise<String> {
        return Promise{ fulfill, reject in
            var ref: DocumentReference? = nil

            let data: [String : Any] = [
                "id"                : "",
                "uid"               : user.uid,
                "userName"          : user.userName,
                "email"             : user.email,
                "points"            : 25,
                "betsWon"           : 0,
                "gamesWon"          : 0,
                "imageDownloadUrl"  : "https://web.usask.ca/images/profile.jpg", //upload own "unwknown" image url.
                "followers"         : [],
                "followings"        : [],
                "timestamp"         : String(describing: Date()),
                "notifications"     : [
                    "newMessage"    : true
                ]
            ]
            
            //Add game - I pray they come up with a better solution for referencing the ref id, this is tacky
            ref = db.collection("Users").addDocument(data: data){err in
                if let err = err {
                    reject(err)
                    print("Error adding document: \(err)")
                } else {
                    
                    //Create new customer object for user.
                    StripeAPIClient.createCustomer(email: user.email)
                        .then{ response -> Void in
                            if let JSON = response.result.value {
                                do{
                                    let json        : NSDictionary  = try JSONSerializer.toDictionary(JSON)
                                    let customerId  : String        = json["id"] as! String
                                    
                                    //Update id and customerId of user
                                    ref!.updateData([
                                        "customerId": customerId,
                                        "id"        : ref!.documentID
                                    ]){err in
                                        if let err = err {
                                            reject(err)
                                        }
                                        
                                        fulfill(ref!.documentID)
                                    }
                                }catch let error as NSError{
                                    reject(error)
                                }
                            }
                        }.always{}
                }
            }
        }
    }
}

extension MyFSRef {
    class func extractUserData(userSnapshot: DocumentSnapshot) -> User {
        let value   : [String:Any]  = userSnapshot.data()
        let user    : User          = User()
        
        user.id                 = value["id"] as! String
        user.uid                = value["uid"] as! String
        user.customerId         = value["customerId"] as! String
        user.points             = value["points"] as! Int
        user.betsWon            = value["betsWon"] as! Int
        user.gamesWon           = value["gamesWon"] as! Int
        user.userName           = value["userName"] as! String
        user.email              = value["email"] as! String
        user.imageDownloadUrl   = value["imageDownloadUrl"] as! String
        user.followers          = value["followers"] as! [String]
        user.followings         = value["followings"] as! [String]
        user.notifications      = value["notifications"] as! [String:Bool]
        user.phoneNumber        = value["phoneNumber"] as? String
        user.fcmToken           = value["fcmToken"] as? String
        user.city               = value["city"] as? String
        user.stateId            = value["stateId"] as? Int
        user.gender             = value["gender"] as? String
        
        return user
    }
    
    class func extractBetData(betSnapshot: DocumentSnapshot) -> Bet {
        let value   : [String:Any]  = betSnapshot.data()
        let bet     : Bet           = Bet()
        
        bet.id          = value["id"] as! String
        bet.userId      = value["userId"] as! String
        bet.gameId      = value["gameId"] as! String
        bet.homeDigit   = value["homeDigit"] as! Int
        bet.homeTeam    = value["homeTeam"] as! String
        bet.awayDigit   = value["awayDigit"] as! Int
        bet.awayTeam    = value["awayTeam"] as! String
        bet.timestamp   = ConversionService.timestampToDate(timestamp: value["timestamp"] as! String)
        
        return bet
    }
    
    class func extractGameData(gameDoc: DocumentSnapshot) -> Game {
        let gameData: [String:Any]  = gameDoc.data()
        let game    : Game          = Game()
        
        game.id             = gameData["id"] as! String
        game.homeTeam       = gameData["homeTeam"] as! String
        game.homeTeamScore  = gameData["homeTeamScore"] as! Int
        game.awayTeam       = gameData["awayTeam"] as! String
        game.awayTeamScore  = gameData["awayTeamScore"] as! Int
        game.status         = gameData["status"] as! Int
        game.starts         = ConversionService.timestampToDate(timestamp: gameData["starts"] as! String)
        game.timestamp      = ConversionService.timestampToDate(timestamp: gameData["timestamp"] as! String)
        game.potAmount      = gameData["potAmount"] as? Double
        game.betPrice       = gameData["betPrice"] as? Double
        game.userId         = gameData["userId"] as? String
        
        return game
    }
}

//http://www.messletters.com/en/big-text/
