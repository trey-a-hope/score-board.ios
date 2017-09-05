struct NBATeam {
    struct Hawks {
        static let id: Int = 1
        static let name: String = "Hawks"
        static let city: String = "Atlanta"
        static let conference: String = "Southeast"
    }
    struct Celtics {
        static let id: Int = 2
        static let name: String = "Celtics"
        static let city: String = "Boston"
        static let conference: String = "Atlantic"
    }
    struct Nets {
        static let id: Int = 3
        static let name: String = "Nets"
        static let city: String = "Brooklyn"
        static let conference: String = "Atlantic"
    }
    struct Hornets {
        static let id: Int = 4
        static let name: String = "Hornets"
        static let city: String = "Charlotte"
        static let conference: String = "Southeast"
    }
    struct Bulls {
        static let id: Int = 5
        static let name: String = "Bulls"
        static let city: String = "Chicago"
        static let conference: String = "Central"
    }
    struct Cavaliers {
        static let id: Int = 6
        static let name: String = "Cavaliers"
        static let city: String = "Cleveland"
        static let conference: String = "Central"
    }
    struct Mavericks {
        static let id: Int = 7
        static let name: String = "Mavericks"
        static let city: String = "Dallas"
        static let conference: String = "Southwest"
    }
    struct Nuggets {
        static let id: Int = 8
        static let name: String = "Nuggets"
        static let city: String = "Denver"
        static let conference: String = "Northwest"
    }
    struct Pistons {
        static let id: Int = 9
        static let name: String = "Pistons"
        static let city: String = "Detroid"
        static let conference: String = "Central"
    }
    struct Warriors {
        static let id: Int = 10
        static let name: String = "Warriors"
        static let city: String = "Golden State"
        static let conference: String = "Pacific"
    }
    struct Rockets {
        static let id: Int = 11
        static let name: String = "Rockets"
        static let city: String = "Houston"
        static let conference: String = "Southwest"
    }
    struct Pacers {
        static let id: Int = 12
        static let name: String = "Pacers"
        static let city: String = "Indiana"
        static let conference: String = "Central"
    }
    struct Clippers {
        static let id: Int = 13
        static let name: String = "Clippers"
        static let city: String = "Los Angeles"
        static let conference: String = "Pacific"
    }
    struct Lakers {
        static let id: Int = 14
        static let name: String = "Lakers"
        static let city: String = "Los Angeles"
        static let conference: String = "Pacific"
    }
    struct Grizzlies {
        static let id: Int = 15
        static let name: String = "Grizzlies"
        static let city: String = "Memphis"
        static let conference: String = "Southwest"
    }
    struct Heat {
        static let id: Int = 16
        static let name: String = "Heat"
        static let city: String = "Miami"
        static let conference: String = "Southeast"
    }
    struct Bucks {
        static let id: Int = 17
        static let name: String = "Bucks"
        static let city: String = "Milwaukee"
        static let conference: String = "Central"
    }
    struct Timberwolves {
        static let id: Int = 18
        static let name: String = "Timberwolves"
        static let city: String = "Minnesota"
        static let conference: String = "Northwest"
    }
    struct Pelicans {
        static let id: Int = 19
        static let name: String = "Pelicans"
        static let city: String = "New Orleans"
        static let conference: String = "Southwest"
    }
    struct Knicks {
        static let id: Int = 20
        static let name: String = "Knicks"
        static let city: String = "New York"
        static let conference: String = "Atlantic"
    }
    struct Thunder {
        static let id: Int = 21
        static let name: String = "Thunder"
        static let city: String = "Oklahoma City"
        static let conference: String = "Northwest"
    }
    struct Magic {
        static let id: Int = 22
        static let name: String = "Magic"
        static let city: String = "Orlando"
        static let conference: String = "Southeast"
    }
    struct _76ers {
        static let id: Int = 23
        static let name: String = "76ers"
        static let city: String = "Philadelphia"
        static let conference: String = "Atlantic"
    }
    struct Suns {
        static let id: Int = 24
        static let name: String = "Suns"
        static let city: String = "Phoenix"
        static let conference: String = "Pacific"
    }
    struct TrailBlazers {
        static let id: Int = 25
        static let name: String = "Trail Blazers"
        static let city: String = "Portland"
        static let conference: String = "Northwest"
    }
    struct Kings {
        static let id: Int = 26
        static let name: String = "Kings"
        static let city: String = "Sacramento"
        static let conference: String = "Pacific"
    }
    struct Spurs {
        static let id: Int = 27
        static let name: String = "Spurs"
        static let city: String = "San Antonio"
        static let conference: String = "Southwest"
    }
    struct Raptors {
        static let id: Int = 28
        static let name: String = "Raptors"
        static let city: String = "Toronto"
        static let conference: String = "Atlantic"
    }
    struct Jazz {
        static let id: Int = 29
        static let name: String = "Jazz"
        static let city: String = "Utah"
        static let conference: String = "Northwest"
    }
    struct Wizards {
        static let id: Int = 30
        static let name: String = "Wizards"
        static let city: String = "Washington"
        static let conference: String = "Southeast"
    }
}

class NBATeamService {
    static func getNBATeamName(id: Int) -> String {
        switch (id) {
        case NBATeam.Hawks.id:
            return NBATeam.Hawks.name
        case NBATeam.Celtics.id:
            return NBATeam.Celtics.name
        case NBATeam.Nets.id:
            return NBATeam.Nets.name
        case NBATeam.Hornets.id:
            return NBATeam.Hornets.name
        case NBATeam.Bulls.id:
            return NBATeam.Bulls.name
        case NBATeam.Cavaliers.id:
            return NBATeam.Cavaliers.name
        case NBATeam.Mavericks.id:
            return NBATeam.Mavericks.name
        case NBATeam.Nuggets.id:
            return NBATeam.Nuggets.name
        case NBATeam.Pistons.id:
            return NBATeam.Pistons.name
        case NBATeam.Warriors.id:
            return NBATeam.Warriors.name
        case NBATeam.Rockets.id:
            return NBATeam.Rockets.name
        case NBATeam.Pacers.id:
            return NBATeam.Pacers.name
        case NBATeam.Clippers.id:
            return NBATeam.Clippers.name
        case NBATeam.Lakers.id:
            return NBATeam.Lakers.name
        case NBATeam.Grizzlies.id:
            return NBATeam.Grizzlies.name
        case NBATeam.Heat.id:
            return NBATeam.Heat.name
        case NBATeam.Bucks.id:
            return NBATeam.Bucks.name
        case NBATeam.Timberwolves.id:
            return NBATeam.Timberwolves.name
        case NBATeam.Pelicans.id:
            return NBATeam.Pelicans.name
        case NBATeam.Knicks.id:
            return NBATeam.Knicks.name
        case NBATeam.Thunder.id:
            return NBATeam.Thunder.name
        case NBATeam.Magic.id:
            return NBATeam.Magic.name
        case NBATeam._76ers.id:
            return NBATeam._76ers.name
        case NBATeam.Suns.id:
            return NBATeam.Suns.name
        case NBATeam.TrailBlazers.id:
            return NBATeam.TrailBlazers.name
        case NBATeam.Kings.id:
            return NBATeam.Kings.name
        case NBATeam.Spurs.id:
            return NBATeam.Spurs.name
        case NBATeam.Raptors.id:
            return NBATeam.Raptors.name
        case NBATeam.Jazz.id:
            return NBATeam.Jazz.name
        case NBATeam.Wizards.id:
            return NBATeam.Wizards.name
        default:
            return "Team Name Not Found"
        }
    }
}
