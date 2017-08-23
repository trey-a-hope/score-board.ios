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

    
}


