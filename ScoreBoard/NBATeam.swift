import UIKit

class NBATeam {
    var id: Int!
    var name: String!
    var city: String!
    var conference: String!
    var imageDownloadUrl: String!
    var backgroundColor: UIColor!
    
    init(id: Int, name: String, city: String, conference: String, imageDownloadUrl: String, hexColor: String) {
        self.id = id
        self.name = name
        self.city = city
        self.conference = conference
        self.imageDownloadUrl = imageDownloadUrl
        self.backgroundColor = UIColor().hexStringToUIColor(hex: hexColor)
    }
}

class NBATeamService {
    private var teams: [NBATeam] = [NBATeam]()
    static let instance = NBATeamService()
    
    init() {
        //Atlanta Hawks
        teams.append(NBATeam(id: 1, name: "Hawks", city: "Atlanta", conference: "Southeast", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FHawks.png?alt=media&token=db513f9a-6f96-4d47-8a64-8de603aa89b5", hexColor: "FF0000"))
        //Boston Celtics
        teams.append(NBATeam(id: 2, name: "Celtics", city: "Boston", conference: "Atlantic", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FCeltics.png?alt=media&token=ea2a87e2-c461-41ff-9f36-0325701f5ce0", hexColor: "FF0000"))
        //Brooklyn Nets
        teams.append(NBATeam(id: 3, name: "Nets", city: "Brooklyn", conference: "Atlantic", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FNets.png?alt=media&token=982862cc-14bf-4a21-b81f-27cb1edef075", hexColor: "FF0000"))
        //Charlotte Hornets
        teams.append(NBATeam(id: 4, name: "Hornets", city: "Charlotte", conference: "Southeast", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FHornets.png?alt=media&token=b74f21c1-13e3-44f0-94fb-ebd094072e62", hexColor: "FF0000"))
        //Chicago Bulls
        teams.append(NBATeam(id: 5, name: "Bulls", city: "Chicago", conference: "Central", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FBulls.png?alt=media&token=f9f395ad-f1be-400e-8897-12e9f7490bc4", hexColor: "FF0000"))
        //Cleveland Cavaliers
        teams.append(NBATeam(id: 6, name: "Cavaliers", city: "Cleveland", conference: "Central", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FCavaliers.jpg?alt=media&token=f235146c-7a26-4a0b-8c62-6ea4000a5890", hexColor: "FF0000"))
        //Dallas Mavericks
        teams.append(NBATeam(id: 7, name: "Mavericks", city: "Dallas", conference: "Southwest", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FMavericks.png?alt=media&token=be9f6fcd-66b0-4239-892c-551c72ec2b02", hexColor: "FF0000"))
        //Denver Nuggets: TOOD: NEEDS A BETTER IMAGE
        teams.append(NBATeam(id: 8, name: "Nuggets", city: "Denver", conference: "Northwest", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FNuggets.png?alt=media&token=06b13205-08d2-4ffa-8a5e-0069a6d484a0", hexColor: "FF0000"))
        //Detroit Pistons
        teams.append(NBATeam(id: 9, name: "Pistons", city: "Detroit", conference: "Central", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FPistons.png?alt=media&token=d05dcb48-47b1-4c21-9c52-8ca741fe472f", hexColor: "FF0000"))
        //Golden State Warriors
        teams.append(NBATeam(id: 10, name: "Warriors", city: "Golden State", conference: "Pacific", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FWarriors.jpg?alt=media&token=699e5980-5b16-46e5-8f72-ffa5863be69a", hexColor: "FF0000"))
        //Houston Rockets
        teams.append(NBATeam(id: 11, name: "Rockets", city: "Houston", conference: "Southwest", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FRockets.jpg?alt=media&token=3b570b2e-868a-42c3-a36b-bff5e529bfcc", hexColor: "FF0000"))
        //Indiana Pacers
        teams.append(NBATeam(id: 12, name: "Pacers", city: "Indiana", conference: "Central", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FPacers.png?alt=media&token=9f73d077-8995-4f91-892c-98194d2714af", hexColor: "FF0000"))
        //Los Angeles Clippers
        teams.append(NBATeam(id: 13, name: "Clippers", city: "Los Angeles", conference: "Pacific", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FClippers.jpg?alt=media&token=c42e3463-d0a7-4ce9-8343-0307f6673cd5", hexColor: "FF0000"))
        //Los Angeles Lakers
        teams.append(NBATeam(id: 14, name: "Lakers", city: "Los Angeles", conference: "Pacific", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FLakers.jpg?alt=media&token=a86899ff-078f-4fdf-9f59-7e0a9e1eb82f", hexColor: "FF0000"))
        //Memphis Grizzlies
        teams.append(NBATeam(id: 15, name: "Grizzlies", city: "Memphis", conference: "Southwest", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FGrizzlies.jpg?alt=media&token=4fb12dd8-7a8a-413e-8826-1b21d8f0cdf6", hexColor: "FF0000"))
        //Miami Heat
        teams.append(NBATeam(id: 16, name: "Heat", city: "Miami", conference: "Southeast", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FHeat.jpg?alt=media&token=b96720ec-bcb5-4a31-b865-cb2a440df6c3", hexColor: "FF0000"))
        //Milwaukee Bucks
        teams.append(NBATeam(id: 17, name: "Bucks", city: "Milwaukee", conference: "Central", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FBucks.jpg?alt=media&token=ddb0fe88-37ff-4c4b-aa29-b8b0e5c26b8f", hexColor: "FF0000"))
        //Minnesota Timberwolves
        teams.append(NBATeam(id: 18, name: "Timberwolves", city: "Minnesota", conference: "Northwest", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FTimberwolves.png?alt=media&token=c4fb2d27-a8e8-4146-9e8f-b9702cf084fc", hexColor: "FF0000"))
        //New Orleans Pelicans
        teams.append(NBATeam(id: 19, name: "Pelicans", city: "New Orleans", conference: "Southwest", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FPelicans.jpg?alt=media&token=452d7aff-2683-474e-91d3-43b875fe599d", hexColor: "FF0000"))
        //New York Knicks
        teams.append(NBATeam(id: 20, name: "Knicks", city: "New York", conference: "Atlantic", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FKnicks.jpg?alt=media&token=e0b48f07-b288-4a7e-a552-008872733375", hexColor: "FF0000"))
        //Oklahoma City Thunder
        teams.append(NBATeam(id: 21, name: "Thunder", city: "Oklahoma City", conference: "Northwest", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FThunder.png?alt=media&token=519bcc5b-63a7-4b50-bc83-fe763a7f48c1", hexColor: "FF0000"))
        //Orlando Magic
        teams.append(NBATeam(id: 22, name: "Magic", city: "Orlando", conference: "Southeast", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FMagic.jpeg?alt=media&token=d7325828-43ac-4227-ac82-78b9c0965c6a", hexColor: "FF0000"))
    }
    
    //Id - 1 is the same as position in array.
    func getTeam(id: Int) -> NBATeam {
        return teams[id - 1]
    }
}

//http://www.sportslogos.net/teams/list_by_league/6/National_Basketball_Association/NBA/logos/


//    struct _76ers {
//        static let id: Int = 23
//        static let name: String = "76ers"
//        static let city: String = "Philadelphia"
//        static let conference: String = "Atlantic"
//    }
//    struct Suns {
//        static let id: Int = 24
//        static let name: String = "Suns"
//        static let city: String = "Phoenix"
//        static let conference: String = "Pacific"
//    }
//    struct TrailBlazers {
//        static let id: Int = 25
//        static let name: String = "Trail Blazers"
//        static let city: String = "Portland"
//        static let conference: String = "Northwest"
//    }
//    struct Kings {
//        static let id: Int = 26
//        static let name: String = "Kings"
//        static let city: String = "Sacramento"
//        static let conference: String = "Pacific"
//    }
//    struct Spurs {
//        static let id: Int = 27
//        static let name: String = "Spurs"
//        static let city: String = "San Antonio"
//        static let conference: String = "Southwest"
//    }
//    struct Raptors {
//        static let id: Int = 28
//        static let name: String = "Raptors"
//        static let city: String = "Toronto"
//        static let conference: String = "Atlantic"
//    }
//    struct Jazz {
//        static let id: Int = 29
//        static let name: String = "Jazz"
//        static let city: String = "Utah"
//        static let conference: String = "Northwest"
//    }
//    struct Wizards {
//        static let id: Int = 30
//        static let name: String = "Wizards"
//        static let city: String = "Washington"
//        static let conference: String = "Southeast"
//    }
//}

//class NBATeamService {
//    static func getNBATeamImage(id: Int) -> String {
//        switch (id) {
//        case NBATeam.Hawks.id:
//            return NBATeam.Hawks.imageDownloadUrl
//        case NBATeam.Celtics.id:
//            return NBATeam.Celtics.imageDownloadUrl
//        default:
//            return ""
//        }
//    }
//    
//    static func getNBATeamName(id: Int) -> String {
//        switch (id) {
//        case NBATeam.Hawks.id:
//            return NBATeam.Hawks.name
//        case NBATeam.Celtics.id:
//            return NBATeam.Celtics.name
//        case NBATeam.Nets.id:
//            return NBATeam.Nets.name
//        case NBATeam.Hornets.id:
//            return NBATeam.Hornets.name
//        case NBATeam.Bulls.id:
//            return NBATeam.Bulls.name
//        case NBATeam.Cavaliers.id:
//            return NBATeam.Cavaliers.name
//        case NBATeam.Mavericks.id:
//            return NBATeam.Mavericks.name
//        case NBATeam.Nuggets.id:
//            return NBATeam.Nuggets.name
//        case NBATeam.Pistons.id:
//            return NBATeam.Pistons.name
//        case NBATeam.Warriors.id:
//            return NBATeam.Warriors.name
//        case NBATeam.Rockets.id:
//            return NBATeam.Rockets.name
//        case NBATeam.Pacers.id:
//            return NBATeam.Pacers.name
//        case NBATeam.Clippers.id:
//            return NBATeam.Clippers.name
//        case NBATeam.Lakers.id:
//            return NBATeam.Lakers.name
//        case NBATeam.Grizzlies.id:
//            return NBATeam.Grizzlies.name
//        case NBATeam.Heat.id:
//            return NBATeam.Heat.name
//        case NBATeam.Bucks.id:
//            return NBATeam.Bucks.name
//        case NBATeam.Timberwolves.id:
//            return NBATeam.Timberwolves.name
//        case NBATeam.Pelicans.id:
//            return NBATeam.Pelicans.name
//        case NBATeam.Knicks.id:
//            return NBATeam.Knicks.name
//        case NBATeam.Thunder.id:
//            return NBATeam.Thunder.name
//        case NBATeam.Magic.id:
//            return NBATeam.Magic.name
//        case NBATeam._76ers.id:
//            return NBATeam._76ers.name
//        case NBATeam.Suns.id:
//            return NBATeam.Suns.name
//        case NBATeam.TrailBlazers.id:
//            return NBATeam.TrailBlazers.name
//        case NBATeam.Kings.id:
//            return NBATeam.Kings.name
//        case NBATeam.Spurs.id:
//            return NBATeam.Spurs.name
//        case NBATeam.Raptors.id:
//            return NBATeam.Raptors.name
//        case NBATeam.Jazz.id:
//            return NBATeam.Jazz.name
//        case NBATeam.Wizards.id:
//            return NBATeam.Wizards.name
//        default:
//            return "Team Name Not Found"
//        }
//    }
//}
