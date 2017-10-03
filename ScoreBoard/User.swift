import UIKit

class User : FirebaseObject {
    var uid: String!
    var userName: String!
    var userNameLower: String!      //For searching
    var email: String!
    var phoneNumber: String!
    var fcmToken: String!
    var imageDownloadUrl: String!
    var points: Int!
    var betsWon: Int!
    var city: String!
    var stateId: Int!
    var gender: String!
}
