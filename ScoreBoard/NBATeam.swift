class NBATeam {
    var id: Int!
    var name: String!
    var city: String!
    var conference: String!
    var imageDownloadUrl: String!
    
    init(id: Int, name: String, city: String, conference: String, imageDownloadUrl: String) {
        self.id = id
        self.name = name
        self.city = city
        self.conference = conference
        self.imageDownloadUrl = imageDownloadUrl
    }
}

class NBATeamService {
    private var teams: [NBATeam] = [NBATeam]()
    static let instance = NBATeamService()
    
    init() {
        //Atlanta Hawks
        teams.append(NBATeam(id: 1, name: "Hawks", city: "Atlanta", conference: "Southeast", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FHawks.png?alt=media&token=db513f9a-6f96-4d47-8a64-8de603aa89b5"))
        //Boston Celtics
        teams.append(NBATeam(id: 2, name: "Celtics", city: "Boston", conference: "Atlantic", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FCeltics.png?alt=media&token=ea2a87e2-c461-41ff-9f36-0325701f5ce0"))
        //Brooklyn Nets
        teams.append(NBATeam(id: 3, name: "Nets", city: "Brooklyn", conference: "Atlantic", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FNets.png?alt=media&token=982862cc-14bf-4a21-b81f-27cb1edef075"))
        //Charlotte Hornets
        teams.append(NBATeam(id: 4, name: "Hornets", city: "Charlotte", conference: "Southeast", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FHornets.png?alt=media&token=b74f21c1-13e3-44f0-94fb-ebd094072e62"))
        //Chicago Bulls
        teams.append(NBATeam(id: 5, name: "Bulls", city: "Chicago", conference: "Central", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FBulls.png?alt=media&token=f9f395ad-f1be-400e-8897-12e9f7490bc4"))
    }
    
    //Id - 1 is the same as position in array.
    func getTeam(id: Int) -> NBATeam {
        return teams[id - 1]
    }
}



//    struct Cavaliers {
//        static let id: Int = 6
//        static let name: String = "Cavaliers"
//        static let city: String = "Cleveland"
//        static let conference: String = "Central"
//    }
//    struct Mavericks {
//        static let id: Int = 7
//        static let name: String = "Mavericks"
//        static let city: String = "Dallas"
//        static let conference: String = "Southwest"
//    }
//    struct Nuggets {
//        static let id: Int = 8
//        static let name: String = "Nuggets"
//        static let city: String = "Denver"
//        static let conference: String = "Northwest"
//    }
//    struct Pistons {
//        static let id: Int = 9
//        static let name: String = "Pistons"
//        static let city: String = "Detroid"
//        static let conference: String = "Central"
//    }
//    struct Warriors {
//        static let id: Int = 10
//        static let name: String = "Warriors"
//        static let city: String = "Golden State"
//        static let conference: String = "Pacific"
//    }
//    struct Rockets {
//        static let id: Int = 11
//        static let name: String = "Rockets"
//        static let city: String = "Houston"
//        static let conference: String = "Southwest"
//    }
//    struct Pacers {
//        static let id: Int = 12
//        static let name: String = "Pacers"
//        static let city: String = "Indiana"
//        static let conference: String = "Central"
//    }
//    struct Clippers {
//        static let id: Int = 13
//        static let name: String = "Clippers"
//        static let city: String = "Los Angeles"
//        static let conference: String = "Pacific"
//    }
//    struct Lakers {
//        static let id: Int = 14
//        static let name: String = "Lakers"
//        static let city: String = "Los Angeles"
//        static let conference: String = "Pacific"
//    }
//    struct Grizzlies {
//        static let id: Int = 15
//        static let name: String = "Grizzlies"
//        static let city: String = "Memphis"
//        static let conference: String = "Southwest"
//    }
//    struct Heat {
//        static let id: Int = 16
//        static let name: String = "Heat"
//        static let city: String = "Miami"
//        static let conference: String = "Southeast"
//    }
//    struct Bucks {
//        static let id: Int = 17
//        static let name: String = "Bucks"
//        static let city: String = "Milwaukee"
//        static let conference: String = "Central"
//    }
//    struct Timberwolves {
//        static let id: Int = 18
//        static let name: String = "Timberwolves"
//        static let city: String = "Minnesota"
//        static let conference: String = "Northwest"
//    }
//    struct Pelicans {
//        static let id: Int = 19
//        static let name: String = "Pelicans"
//        static let city: String = "New Orleans"
//        static let conference: String = "Southwest"
//    }
//    struct Knicks {
//        static let id: Int = 20
//        static let name: String = "Knicks"
//        static let city: String = "New York"
//        static let conference: String = "Atlantic"
//    }
//    struct Thunder {
//        static let id: Int = 21
//        static let name: String = "Thunder"
//        static let city: String = "Oklahoma City"
//        static let conference: String = "Northwest"
//    }
//    struct Magic {
//        static let id: Int = 22
//        static let name: String = "Magic"
//        static let city: String = "Orlando"
//        static let conference: String = "Southeast"
//    }
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
