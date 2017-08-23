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
//            ref.child(Table.Games).observeSingleEvent(of: .value, with: { (campSnapShots) in
//                var camps: [Camp] = []
//                campSnapShots.children.allObjects.forEach({ (campSnapShot) in
//                    let data = campSnapShot as! DataSnapshot
//                    let value = data.value as! [String:Any]
//                    let camp: Camp = Camp()
//                    /* Set values to camp object. */
//                    camp.id = value["id"] as! String
//                    camp.address = value["address"] as! String
//                    camp.city = value["city"] as! String
//                    camp.endDateTime = ConversionService.convertStringToDate(value["endDateTime"] as! String)
//                    camp.imageDownloadUrl = value["imageDownloadUrl"] as! String
//                    camp.isHBCU = value["isHBCU"] as! Bool
//                    camp.memo = value["memo"] as! String
//                    camp.registrationDateTime = ConversionService.convertStringToDate(value["registrationDateTime"] as! String)
//                    camp.name = value["name"] as! String
//                    camp.stateId = value["stateId"] as! Int
//                    camp.zip = value["zip"] as! String
//                    camp.hyperlink = value["hyperlink"] as! String
//                    camp.timeZoneOffSet = value["timeZoneOffSet"] as! Int
//                    camp.registrationCost = value["registrationCost"] as! Double
//                    camp.startDateTime = ConversionService.convertStringToDate(value["startDateTime"] as! String)
//                    camp.postDateTime = ConversionService.convertStringToDate(value["postDateTime"] as! String)
//                    camps.append(camp)
//                })
//                /* Return camps */
//                print("getCamps: " + String(describing: camps))
//                fulfill(camps)
//            })
        }
    }

    
}


