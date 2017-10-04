import UIKit

class Game : FirebaseObject {
    var awayTeamScore: Int!
    var awayTeamId: Int!
    var homeTeamScore: Int!
    var homeTeamId: Int!
    var startDateTime: Date!
    var startTimeZoneOffSet: Int!
    var activeCode: Int!
    var potAmount: Double!
    
    var homeTeamName: String!
    var homeTeamCity: String!
    var awayTeamName: String!
    var awayTeamCity: String!
        
    //Used only on front end, not saved to firebase.
    var bets: [Bet] = [Bet]()
}
