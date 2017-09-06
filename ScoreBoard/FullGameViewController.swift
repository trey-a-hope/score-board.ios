import SwiftSpinner
import UIKit

class FullGameViewController: UIViewController {
    @IBOutlet weak var homeTeamImage: UIImageView!
    @IBOutlet weak var homeTeamCity: UILabel!
    @IBOutlet weak var homeTeamName: UILabel!
    @IBOutlet weak var awayTeamImage: UIImageView!
    @IBOutlet weak var awayTeamCity: UILabel!
    @IBOutlet weak var awayTeamName: UILabel!
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
                }else{
                    self.betTitle.text = String(describing: self.bets.count) + " Bets"
                }
                self.collectionView.reloadData()
            }.catch{ (error) in
                ModalService.displayAlert(title: "Error", message: error.localizedDescription, vc: self)
            }.always{
                self.setUI()
        }
    }
    
    func setUI() -> Void {
        //Home Team Image
        homeTeamImage.layer.cornerRadius = homeTeamImage.frame.size.width / 2;
        homeTeamImage.clipsToBounds = true;
        homeTeamImage.layer.borderWidth = 2.0
        homeTeamImage.kf.setImage(with: URL(string: homeTeam!.imageDownloadUrl))
        homeTeamImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openTeamWebsite)))
        homeTeamImage.isUserInteractionEnabled = true
        //Home Team City
        homeTeamCity.text = homeTeam!.city
        //Home Team Name
        homeTeamName.text = homeTeam!.name
        //Away Team Image
        awayTeamImage.layer.cornerRadius = awayTeamImage.frame.size.width / 2;
        awayTeamImage.clipsToBounds = true;
        awayTeamImage.layer.borderWidth = 2.0
        awayTeamImage.kf.setImage(with: URL(string: (awayTeam!.imageDownloadUrl)!))
        awayTeamImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openTeamWebsite)))
        awayTeamImage.isUserInteractionEnabled = true
        //Away Team City
        awayTeamCity.text = awayTeam!.city
        //Away Team Name
        awayTeamName.text = awayTeam!.name
        SwiftSpinner.hide()
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
            
            return cell
        }
        fatalError("Unable to Dequeue Reusable Cell View")
    }
    
}

//http://www.sportslogos.net/teams/list_by_league/6/National_Basketball_Association/NBA/logos/
