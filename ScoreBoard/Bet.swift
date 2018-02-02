import UIKit

class Bet {
    var id          : String!
    var homeDigit   : Int!     //Last digit of the home team's score
    var homeTeam    : String!   //Name of team
    var awayDigit   : Int!     //Last digit of the away team's score
    var awayTeam    : String!      //Name of team
    var userId      : String!     //ID of the user who placed the bet
    var gameId      : String!     //ID of the game this bet is for
    var timestamp   : Date!
    
    var user        : User!         //Used only on FE, not saved into Firestore
}
