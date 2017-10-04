import FirebaseFirestore
import FirebaseStorage
import PromiseKit

class MyFSRef {
    private class var db: Firestore {
        return Firestore.firestore()
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
    
    class func getGames()-> Promise<[Game]> {
        var games: [Game] = [Game]()
        return Promise{ fulfill, reject in
            db.collection("Games").getDocuments(completion: { (collection, err) in
                if let err = err { reject(err) }
                for document in (collection?.documents)! {
                    games.append(extractGameData(gameSnapshot: document))
                }
                fulfill(games)
            })
        }
    }
    
    class func createGame(game: Game) -> Promise<String> {
        return Promise{ fulfill, reject in
            var ref: DocumentReference? = nil
            let now: Date = Date()
            
            let data: [String : Any] = [
                "activeCode"            : 0,
                "potAmount"             : game.potAmount,
                "awayTeamScore"         : 0,
                "awayTeamCity"          : game.awayTeamCity,
                "awayTeamName"          : game.awayTeamName,
                "homeTeamScore"         : 0,
                "homeTeamCity"          : game.homeTeamCity,
                "homeTeamName"          : game.homeTeamName,
                "startDateTime"         : ConversionService.convertDateToFirebaseString(now),
                "startTimeZoneOffSet"   : now.getTimeZoneOffset(),
                "postDateTime"          : ConversionService.convertDateToFirebaseString(now),
                "postTimeZoneOffSet"    : now.getTimeZoneOffset()
            ]
            
//            print(data)
//            fulfill("GOT IT")
            
            //Add game
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
    
    private class func extractGameData(gameSnapshot: DocumentSnapshot) -> Game {
        let value = gameSnapshot.data()
        let game: Game = Game()
        
        game.id = value["id"] as! String
        game.postTimeZoneOffSet = value["postTimeZoneOffSet"] as! Int
        game.postDateTime = ConversionService.convertStringToDate(value["postDateTime"] as! String)
        game.awayTeamScore = value["awayTeamScore"] as! Int
        game.awayTeamCity = value["awayTeamCity"] as! String
        game.awayTeamName = value["awayTeamName"] as! String
        game.homeTeamScore = value["homeTeamScore"] as! Int
        game.homeTeamCity = value["homeTeamCity"] as! String
        game.homeTeamName = value["homeTeamName"] as! String
        game.startTimeZoneOffSet = value["startTimeZoneOffSet"] as! Int
        game.startDateTime = ConversionService.convertStringToDate(value["startDateTime"] as! String)
        game.activeCode = value["activeCode"] as! Int
        game.potAmount = value["potAmount"] as! Double
        
        let betSnapshots = value["bets"] as? [String:Any]
        
        //If this game has bets currently...
        if let _ = betSnapshots {
            for betSnapshot in betSnapshots! {
                let betSnapshot = betSnapshot.value as! [String:Any]
                let bet: Bet = Bet()
                bet.id = betSnapshot["id"] as! String
                bet.postDateTime = ConversionService.convertStringToDate(betSnapshot["postDateTime"] as! String)
                bet.postTimeZoneOffSet = value["postTimeZoneOffSet"] as! Int
                bet.userId = betSnapshot["userId"] as! String
                bet.awayDigit = betSnapshot["awayDigit"] as! Int
                bet.homeDigit = betSnapshot["homeDigit"] as! Int
                
                game.bets.append(bet)
            }
        }
        
        return (game)
    }
}
