import UIKit

class Game : FirebaseObject {
    var userId: String!
    var awayTeamScore: Int!
    var awayTeamId: Int!
    var homeTeamScore: Int!
    var homeTeamId: Int!
    var startDateTime: Date!
    var startTimeZoneOffSet: Int!
    var activeCode: Int!
    var potAmount: Double!
    var betPrice: Double!
}
