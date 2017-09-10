import UIKit

class Bet : FirebaseObject {
    var awayDigit: Int!
    var homeDigit: Int!
    var userId: String!
    
    var user: User! //Only used on front end, is not saved on backend.
}
