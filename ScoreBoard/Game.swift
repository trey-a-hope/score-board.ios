import UIKit

class Game {
    var id                  : String!
    var userId              : String!   //ID of the user who owns this game
    var awayTeam            : String!   //Name of team
    var awayTeamScore       : Int!
    var homeTeam            : String!   //Name of team
    var homeTeamScore       : Int!
    var starts              : Date!     //Time game starts.
    var status              : Int!      //Pre(before), Active(current), Post(after)
    var potAmount           : Double!   //Winning amount for the game.
    var betPrice            : Double!
    var timestamp           : Date!     //Time game was posted.
}
