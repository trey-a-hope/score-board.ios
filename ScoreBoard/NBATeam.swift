import UIKit

class NBATeam {
    var id: Int!
    var name: String!
    var city: String!
    var conference: String!
    var imageDownloadUrl: String!
    var backgroundColor: UIColor!
    var url: String!
    
    init(id: Int, name: String, city: String, conference: String, imageDownloadUrl: String, hexColor: String, url: String) {
        self.id = id
        self.name = name
        self.city = city
        self.conference = conference
        self.imageDownloadUrl = imageDownloadUrl
        self.backgroundColor = UIColor().hexStringToUIColor(hex: hexColor)
        self.url = url
    }
}

class NBATeamService {
    public var teams: [NBATeam] = [NBATeam]()
    static let instance = NBATeamService()
    
    init() {
        //Atlanta Hawks
        teams.append(NBATeam(id: 1, name: "Hawks", city: "Atlanta", conference: "Southeast", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FHawks.png?alt=media&token=db513f9a-6f96-4d47-8a64-8de603aa89b5", hexColor: "E03A3E", url: "http://www.nba.com/teams/hawks"))
        //Boston Celtics
        teams.append(NBATeam(id: 2, name: "Celtics", city: "Boston", conference: "Atlantic", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FCeltics.png?alt=media&token=ea2a87e2-c461-41ff-9f36-0325701f5ce0", hexColor: "008348", url: "http://www.nba.com/teams/celtics"))
        //Brooklyn Nets
        teams.append(NBATeam(id: 3, name: "Nets", city: "Brooklyn", conference: "Atlantic", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FNets.png?alt=media&token=982862cc-14bf-4a21-b81f-27cb1edef075", hexColor: "000000", url: "http://www.nba.com/teams/nets"))
        //Charlotte Hornets
        teams.append(NBATeam(id: 4, name: "Hornets", city: "Charlotte", conference: "Southeast", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FHornets.png?alt=media&token=b74f21c1-13e3-44f0-94fb-ebd094072e62", hexColor: "1D1160", url: "http://www.nba.com/teams/hornets"))
        //Chicago Bulls
        teams.append(NBATeam(id: 5, name: "Bulls", city: "Chicago", conference: "Central", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FBulls.png?alt=media&token=f9f395ad-f1be-400e-8897-12e9f7490bc4", hexColor: "CE1141", url: "http://www.nba.com/teams/bulls"))
        //Cleveland Cavaliers
        teams.append(NBATeam(id: 6, name: "Cavaliers", city: "Cleveland", conference: "Central", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FCavaliers.jpg?alt=media&token=f235146c-7a26-4a0b-8c62-6ea4000a5890", hexColor: "860038", url: "http://www.nba.com/teams/cavaliers"))
        //Dallas Mavericks
        teams.append(NBATeam(id: 7, name: "Mavericks", city: "Dallas", conference: "Southwest", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FMavericks.png?alt=media&token=be9f6fcd-66b0-4239-892c-551c72ec2b02", hexColor: "007DC5", url: "http://www.nba.com/teams/mavericks"))
        //Denver Nuggets: TOOD: NEEDS A BETTER IMAGE
        teams.append(NBATeam(id: 8, name: "Nuggets", city: "Denver", conference: "Northwest", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FNuggets.png?alt=media&token=06b13205-08d2-4ffa-8a5e-0069a6d484a0", hexColor: "4FA8FF", url: "http://www.nba.com/teams/nuggets"))
        //Detroit Pistons
        teams.append(NBATeam(id: 9, name: "Pistons", city: "Detroit", conference: "Central", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FPistons.png?alt=media&token=d05dcb48-47b1-4c21-9c52-8ca741fe472f", hexColor: "001F70", url: "http://www.nba.com/teams/pistons"))
        //Golden State Warriors
        teams.append(NBATeam(id: 10, name: "Warriors", city: "Golden State", conference: "Pacific", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FWarriors.jpg?alt=media&token=699e5980-5b16-46e5-8f72-ffa5863be69a", hexColor: "006BB6", url: "http://www.nba.com/teams/warriors"))
        //Houston Rockets
        teams.append(NBATeam(id: 11, name: "Rockets", city: "Houston", conference: "Southwest", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FRockets.jpg?alt=media&token=3b570b2e-868a-42c3-a36b-bff5e529bfcc", hexColor: "CE1141", url: "http://www.nba.com/teams/rockets"))
        //Indiana Pacers
        teams.append(NBATeam(id: 12, name: "Pacers", city: "Indiana", conference: "Central", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FPacers.png?alt=media&token=9f73d077-8995-4f91-892c-98194d2714af", hexColor: "00275D", url: "http://www.nba.com/teams/pacers"))
        //Los Angeles Clippers
        teams.append(NBATeam(id: 13, name: "Clippers", city: "Los Angeles", conference: "Pacific", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FClippers.jpg?alt=media&token=c42e3463-d0a7-4ce9-8343-0307f6673cd5", hexColor: "ED174C", url: "http://www.nba.com/teams/clippers"))
        //Los Angeles Lakers
        teams.append(NBATeam(id: 14, name: "Lakers", city: "Los Angeles", conference: "Pacific", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FLakers.jpg?alt=media&token=a86899ff-078f-4fdf-9f59-7e0a9e1eb82f", hexColor: "552582", url: "http://www.nba.com/teams/lakers"))
        //Memphis Grizzlies
        teams.append(NBATeam(id: 15, name: "Grizzlies", city: "Memphis", conference: "Southwest", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FGrizzlies.jpg?alt=media&token=4fb12dd8-7a8a-413e-8826-1b21d8f0cdf6", hexColor: "23375B", url: "http://www.nba.com/teams/grizzlies"))
        //Miami Heat
        teams.append(NBATeam(id: 16, name: "Heat", city: "Miami", conference: "Southeast", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FHeat.jpg?alt=media&token=b96720ec-bcb5-4a31-b865-cb2a440df6c3", hexColor: "98002E", url: "http://www.nba.com/teams/heat"))
        //Milwaukee Bucks
        teams.append(NBATeam(id: 17, name: "Bucks", city: "Milwaukee", conference: "Central", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FBucks.jpg?alt=media&token=ddb0fe88-37ff-4c4b-aa29-b8b0e5c26b8f", hexColor: "00471B", url: "http://www.nba.com/teams/bucks"))
        //Minnesota Timberwolves
        teams.append(NBATeam(id: 18, name: "Timberwolves", city: "Minnesota", conference: "Northwest", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FTimberwolves.png?alt=media&token=c4fb2d27-a8e8-4146-9e8f-b9702cf084fc", hexColor: "002B5C", url: "http://www.nba.com/teams/timberwolves"))
        //New Orleans Pelicans
        teams.append(NBATeam(id: 19, name: "Pelicans", city: "New Orleans", conference: "Southwest", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FPelicans.jpg?alt=media&token=452d7aff-2683-474e-91d3-43b875fe599d", hexColor: "002B5C", url: "http://www.nba.com/teams/pelicans"))
        //New York Knicks
        teams.append(NBATeam(id: 20, name: "Knicks", city: "New York", conference: "Atlantic", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FKnicks.jpg?alt=media&token=e0b48f07-b288-4a7e-a552-008872733375", hexColor: "006BB6", url: "http://www.nba.com/teams/knicks"))
        //Oklahoma City Thunder
        teams.append(NBATeam(id: 21, name: "Thunder", city: "Oklahoma City", conference: "Northwest", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FThunder.png?alt=media&token=519bcc5b-63a7-4b50-bc83-fe763a7f48c1", hexColor: "002D62", url: "http://www.nba.com/teams/thunder"))
        //Orlando Magic
        teams.append(NBATeam(id: 22, name: "Magic", city: "Orlando", conference: "Southeast", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FMagic.jpeg?alt=media&token=d7325828-43ac-4227-ac82-78b9c0965c6a", hexColor: "007DC5", url: "http://www.nba.com/teams/magic"))
        //Philadelphia 76ers
        teams.append(NBATeam(id: 23, name: "76ers", city: "Philadelphia", conference: "Atlantic", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2F76ers.png?alt=media&token=3130f767-a63d-450e-8e4e-862b139850fc", hexColor: "006BB6", url: "http://www.nba.com/teams/sixers"))
        //Phoenix Suns
        teams.append(NBATeam(id: 24, name: "Suns", city: "Phoenix", conference: "Pacific", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FSuns.png?alt=media&token=33a5fc75-5c05-4f3f-b31a-14717d1ec81a", hexColor: "E56020", url: "http://www.nba.com/teams/suns"))
        //Portland TrailBlazers
        teams.append(NBATeam(id: 25, name: "Trail Blazers", city: "Portland", conference: "Northwest", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FTrailBlazers.jpg?alt=media&token=83cc1654-aa94-4fc4-b24c-ce7546c967a9", hexColor: "F0163A", url: "http://www.nba.com/teams/blazers"))
        //Sacramento Kings
        teams.append(NBATeam(id: 26, name: "Kings", city: "Sacramento", conference: "Pacific", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FKings.png?alt=media&token=7ec05bbc-b596-4ad5-b58d-f195d31cf9d8", hexColor: "724C9F", url: "http://www.nba.com/teams/kings"))
        //San Antonio Spurs
        teams.append(NBATeam(id: 27, name: "Spurs", city: "San Antonio", conference: "Southwest", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FSpurs.png?alt=media&token=a32a1c18-9db2-431f-9c67-44cd3aff9e4a", hexColor: "B6BFBF", url: "http://www.nba.com/teams/spurs"))
        //Toronto Raptors
        teams.append(NBATeam(id: 28, name: "Raptors", city: "Toronto", conference: "Atlantic", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FRaptors.png?alt=media&token=b8db4dd0-90b6-4545-813b-59800abc5286", hexColor: "CE1141", url: "http://www.nba.com/teams/raptors"))
        //Utah Jazz
        teams.append(NBATeam(id: 29, name: "Jazz", city: "Utah", conference: "Northwest", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FJazz.jpg?alt=media&token=510bb7b7-3cf2-4747-af7e-203fbbeddf5f", hexColor: "00471B", url: "http://www.nba.com/teams/jazz"))
        //Washington Wizards
        teams.append(NBATeam(id: 30, name: "Wizards", city: "Washington", conference: "Southeast", imageDownloadUrl: "https://firebasestorage.googleapis.com/v0/b/project-4262310415987696317.appspot.com/o/Images%2FNBATeams%2FWizards.png?alt=media&token=b0068f69-01ae-46de-ac39-cd01ea202cfb", hexColor: "002566", url: "http://www.nba.com/teams/wizards"))
    }
}

//http://www.sportslogos.net/teams/list_by_league/6/National_Basketball_Association/NBA/logos/
