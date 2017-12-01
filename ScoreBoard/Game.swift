import UIKit

class Game {
    var id                  : String!
    var userId              : String!             //ID of the user who owns this game
    var awayTeamScore       : Int!
    var awayTeamId          : Int!
    var homeTeamScore       : Int!
    var homeTeamId          : Int!
    var startDateTime       : Date!
    var startTimeZoneOffSet : Int!
    var status              : Int!
    var potAmount           : Double!
    var betPrice            : Double!
    var timestamp           : Date!
}
