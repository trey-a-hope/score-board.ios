import UIKit

class Bet : FirebaseObject {
    var homeDigit: Int!
    var homeTeamId: Int!
    var awayDigit: Int!
    var awayTeamId: Int!
    var userId: String!
    var gameId: String!
    
    var user: User!//Used only on FE, not saved into Firestore
}
