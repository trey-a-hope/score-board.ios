import SwiftSpinner
import UIKit

class FullGameViewController: UIViewController {
    @IBOutlet weak var homeTeamImage: UIImageView!
    @IBOutlet weak var homeTeamView: UIView!
    @IBOutlet weak var homeTeamCity: UILabel!
    @IBOutlet weak var homeTeamName: UILabel!
    @IBOutlet weak var homeTeamDigit: UILabel!
    @IBOutlet weak var awayTeamImage: UIImageView!
    @IBOutlet weak var awayTeamView: UIView!
    @IBOutlet weak var awayTeamCity: UILabel!
    @IBOutlet weak var awayTeamName: UILabel!
    @IBOutlet weak var awayTeamDigit: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var betTitle: UILabel!
    let CellIdentifier: String = "Cell"
    let BetCellWidth: CGFloat = CGFloat(175)
    var game: Game = Game()
    var homeTeam: NBATeam?
    var awayTeam: NBATeam?
    var bets: [Bet] = [Bet]()
    public var gameId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(ConnectionManager.isConnectedToInternet()){
            initUI()
            getGame()
        }else{
            ModalService.displayNoInternetAlert(vc: self)
        }
    }
    
    func initUI() -> Void {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let XIBCell = UINib.init(nibName: "BetCell", bundle: nil)
        collectionView.register(XIBCell, forCellWithReuseIdentifier: CellIdentifier)
    }
    
    func getGame() -> Void {
        //Get game.
        SwiftSpinner.show("Loading game...")
        MyFirebaseRef.getGame(gameId: gameId!)
            .then{ (game) -> Void in
                self.game = game
                
                //Set home/away teams
                self.homeTeam = NBATeamService.instance.getTeam(id: game.homeTeamId)
                self.awayTeam = NBATeamService.instance.getTeam(id: game.awayTeamId)

                self.getBets()
            }.catch{ (error) in
            }
            .always {
                SwiftSpinner.hide()
            }
    }
    
    func getBets() -> Void {
        //Get bets for game.
        SwiftSpinner.show("Getting bets...")
        
        MyFirebaseRef.getBets(gameId: game.id)
            .then{ (bets) -> Void in
                self.bets = bets
                //Set bet count for label.
                if(self.bets.count == 0){
                    self.betTitle.text = "No Bets"
                }
                else if(self.bets.count == 1){
                    self.betTitle.text = String(describing: self.bets.count) + " Bet"
                }else{
                    self.betTitle.text = String(describing: self.bets.count) + " Bets"
                }
                self.collectionView.reloadData()
            }.catch{ (error) in
                ModalService.displayAlert(title: "Error", message: error.localizedDescription, vc: self)
            }.always{
                self.setUI()
                SwiftSpinner.hide()
        }
    }
    
    func setUI() -> Void {
        let homeScore: Int = 75
        let awayScore: Int = 34
        
        self.navigationController?.visibleViewController?.title = String(describing: homeScore) + " - " + String(describing: awayScore)
        
        //Home Team Digit
        homeTeamDigit.text = "5"
        
        //Home Team Image
        homeTeamImage.round(0, UIColor.black)
        homeTeamImage.kf.setImage(with: URL(string: homeTeam!.imageDownloadUrl))
        homeTeamImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openTeamWebsite)))
        homeTeamImage.isUserInteractionEnabled = true
        
        //Home Team City
        homeTeamCity.text = "Home - " + homeTeam!.city
        
        //Home Team Name
        homeTeamName.text = homeTeam!.name
        
        //Home Team View
        homeTeamView.backgroundColor = homeTeam?.backgroundColor
        
        
        //Away Team Digit
        awayTeamDigit.text = "4"
        
        //Away Team Image
        awayTeamImage.round(0, UIColor.black)
        awayTeamImage.kf.setImage(with: URL(string: (awayTeam!.imageDownloadUrl)!))
        awayTeamImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openTeamWebsite)))
        awayTeamImage.isUserInteractionEnabled = true
        
        //Away Team City
        awayTeamCity.text = "Away - " + awayTeam!.city
        
        //Away Team Name
        awayTeamName.text = awayTeam!.name
        
        //Away Team View
        awayTeamView.backgroundColor = awayTeam?.backgroundColor

    }
    
    func openTeamWebsite() -> Void {
        ModalService.displayAlert(title: "Alert", message: "This will go to the teams website.", vc: self)
    }
}

extension FullGameViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    /* Child section dimensions. */
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        /* NOTE: Height here should always equal height in XIB file. */
        return CGSize(width: BetCellWidth, height: collectionView.bounds.height)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    @objc(collectionView:layout:minimumLineSpacingForSectionAtIndex:) func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}

extension FullGameViewController: UICollectionViewDataSource {
    /* Collection View Data Source Methods. */
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedBet: Bet = bets[indexPath.row]
        
        ModalService.displayAlert(title: selectedBet.userId, message: selectedBet.userName, vc: self)
//        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//        let fullCampViewController = storyBoard.instantiateViewController(withIdentifier: "FullCampViewController") as! FullCampViewController
//        fullCampViewController._camp = selectedCamp
//        fullCampViewController._relatedCamps = RandomService.getRelatedCamps(camp, relatedCamps)
//        fullCampViewController.transitioningFromProfileView = false
//        self.navigationController!.pushViewController(fullCampViewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath) as? BetCell{
            
            let selectedBet: Bet = bets[indexPath.row]
            cell.userName.text = selectedBet.userName
            cell.userImage.kf.setImage(with: URL(string: selectedBet.userImageDownloadUrl))
            cell.userImage.round(1, UIColor.black)
            cell.homeTeamImage.kf.setImage(with: URL(string: homeTeam!.imageDownloadUrl))
            cell.homeTeamImage.round(1, UIColor.black)
            cell.homeTeamDigit.text = String(describing: selectedBet.homeDigit!)
            cell.awayTeamImage.kf.setImage(with: URL(string: awayTeam!.imageDownloadUrl))
            cell.awayTeamImage.round(1, UIColor.black)
            cell.awayTeamDigit.text = String(describing: selectedBet.awayDigit!)
            
            let d: Date = ConversionService.getDateInTimeZone(date: selectedBet.postDateTime, timeZoneOffset: selectedBet.timeZoneOffSet)
            cell.posted.text = ConversionService.timeAgoSinceDate(date: d)
            
            return cell
        }
        fatalError("Unable to Dequeue Reusable Cell View")
    }
    
}


