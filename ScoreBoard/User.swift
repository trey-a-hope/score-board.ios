import UIKit

class User {
    var id                  : String!
    var uid                 : String!                //Unique id from authentication
    var customerId          : String!
    var userName            : String!
    var email               : String!
    var phoneNumber         : String!
    var fcmToken            : String!           //Token used for FCM
    var imageDownloadUrl    : String!
    var points              : Int!
    var betsWon             : Int!
    var gamesWon            : Int!
    var city                : String!
    var stateId             : Int!
    var gender              : String!
    var timestamp           : Date!
}
