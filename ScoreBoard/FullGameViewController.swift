import PopupDialog
import PromiseKit
import SwiftSpinner
import UIKit

class FullGameViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    //Info
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
    //Current Bets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var betTitle: UILabel!
    //Place New Bet
    var betCost: Double = 1.00
    @IBOutlet weak var betCostLabel: UILabel!
    @IBOutlet weak var newBetHomeTeamImage: UIImageView!
    @IBOutlet weak var newBetAwayTeamImage: UIImageView!
    @IBOutlet weak var newBetAwayDigitStepper: UIStepper!
    @IBOutlet weak var newBetHomeDigitStepper: UIStepper!
    @IBOutlet weak var newBetHomeDigit: UILabel!
    @IBOutlet weak var newBetAwayDigit: UILabel!
    @IBOutlet weak var submit: UIButton!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(FullGameViewController.getGame), for: UIControlEvents.valueChanged)
        return refreshControl
    }()

    let CellIdentifier: String = "Cell"
    let BetCellWidth: CGFloat = CGFloat(175)
    var game: Game = Game()
    var homeTeam: NBATeam?
    var awayTeam: NBATeam?
    var bets: [Bet] = [Bet]()
    public var gameId: String?//Passed from the GamesViewController.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(ConnectionManager.isConnectedToInternet()){
            initUI()
            getGame()
        }else{
            ModalService.showError(title: "Error", message: "No internet connection.")
        }
    }
    
    func initUI() -> Void {
        self.scrollView.addSubview(self.refreshControl)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let XIBCell = UINib.init(nibName: "BetCell", bundle: nil)
        collectionView.register(XIBCell, forCellWithReuseIdentifier: CellIdentifier)
        
        /* Refresh Button */
        let refreshButton = UIBarButtonItem(
            title: "Share",
            style: .plain,
            target: self,
            action: #selector(FullGameViewController.share)
        )
        refreshButton.setTitleTextAttributes(Constants.FONT_AWESOME_ATTRIBUTES, for: .normal)
        refreshButton.title = String.fontAwesomeIcon(name: .shareAlt)
        refreshButton.tintColor = .white
        /* Add buttons to nav bar */
        navigationItem.setRightBarButtonItems([refreshButton], animated: false)
        
    }
    
    func getGame() -> Void {
        //Get game.
        SwiftSpinner.show("Loading game...")
        MyFirebaseRef.getGame(gameId: gameId!)
            .then{ (gameBundle) -> Void in
                self.game = gameBundle.game
                self.bets = gameBundle.bets
                
                //Set home/away teams
                self.homeTeam = NBATeamService.instance.getTeam(id: self.game.homeTeamId)
                self.awayTeam = NBATeamService.instance.getTeam(id: self.game.awayTeamId)

                SwiftSpinner.show("Getting bets...")
                self.getUsersInfoForBets()
                    .then{ () -> Void in
                        self.setUI()
                    }.catch{ (error) in
                        
                    }.always{
                        self.refreshControl.endRefreshing()
                        SwiftSpinner.hide()
                    }
            }.catch{ (error) in
                ModalService.showError(title: "Sorry", message: error.localizedDescription)
            }
            .always {
                SwiftSpinner.hide()
            }
    }
    
    func getUsersInfoForBets() -> Promise<Void> {
        //Get bets for game.
        SwiftSpinner.show("Getting bets...")
        return Promise { fulfill, reject in
            if(self.bets.isEmpty){
                fulfill()
            }
            
            var count: Int = 0
            for bet in self.bets {
                MyFirebaseRef.getUserByID(id: bet.userId)
                    .then{ (user) -> Void in
                        bet.user = user
                        
                    }.catch{ (error) in
                        
                    }.always{
                        count += 1

                        if(count == self.bets.count){
                            fulfill()
                        }
                    }
            }
        }
    }
    
    func setUI() -> Void {
        //Set bet count for label.
        if(self.bets.count == 0){
            self.betTitle.text = "No Bets"
        }
        else if(self.bets.count == 1){
            self.betTitle.text = String(describing: self.bets.count) + " Bet"
        }else{
            self.betTitle.text = String(describing: self.bets.count) + " Bets"
        }
        
        //Calculate bet cost (1 + ( 2 * numberOfBets) ).
        self.betCost = 1.00
        for bet in self.bets{
            if(bet.userId == SessionManager.getUserId()){
                self.betCost += 2
            }
        }
        
        //Set Bet Cost
        betCostLabel.text = String(format: "$%.02f", betCost)
        
        //Sort Bets by time.
        self.bets = self.bets.sorted(by: { $0.postDateTime > $1.postDateTime })
        
        self.collectionView.reloadData()

        //Home Team Digit
        homeTeamDigit.text = "5"
        
        //Home Team Image
        homeTeamImage.round(0, UIColor.black)
        homeTeamImage.kf.setImage(with: URL(string: homeTeam!.imageDownloadUrl))
        homeTeamImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openTeamWebsite)))
        homeTeamImage.isUserInteractionEnabled = true
        newBetHomeTeamImage.round(0, UIColor.black)
        newBetHomeTeamImage.kf.setImage(with: URL(string: homeTeam!.imageDownloadUrl))
        
        //Home Team City
        homeTeamCity.text = "Home - " + homeTeam!.city
        
        //Home Team Name
        homeTeamName.text = homeTeam!.name
        
        //Home Team View
        homeTeamView.backgroundColor = homeTeam!.backgroundColor
        
        
        //Away Team Digit
        awayTeamDigit.text = "4"
        
        //Away Team Image
        awayTeamImage.round(0, UIColor.black)
        awayTeamImage.kf.setImage(with: URL(string: (awayTeam!.imageDownloadUrl)!))
        awayTeamImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openTeamWebsite)))
        awayTeamImage.isUserInteractionEnabled = true
        newBetAwayTeamImage.round(0, UIColor.black)
        newBetAwayTeamImage.kf.setImage(with: URL(string: awayTeam!.imageDownloadUrl))
        
        //Away Team City
        awayTeamCity.text = "Away - " + awayTeam!.city
        
        //Away Team Name
        awayTeamName.text = awayTeam!.name
        
        //Away Team View
        awayTeamView.backgroundColor = awayTeam!.backgroundColor

    }
    
    func openTeamWebsite() -> Void {
        ModalService.showInfo(title: "Alert", message: "This will go to the teams website.")
    }
    
    func share() -> Void {
        ModalService.showInfo(title: "Share", message: "Coming Soon.")
    }
    
    @IBAction func submitAction(_ sender: UIButton) {
        if(game.activeCode == 2){
            ModalService.showError(title: "Game Has Ended", message: "You can only bet on 'Pre' games.")
        }else if(game.activeCode == 1){
            ModalService.showError(title: "Game Is In Progress", message: "You can only bet on 'Pre' games.")
        }else{
            let newBetHomeDigit: Int = Int(self.newBetHomeDigitStepper.value)
            let newBetAwayDigit: Int = Int(self.newBetAwayDigitStepper.value)
            //Validate bet is not already taken.
            if(betTaken(homeDigit: newBetHomeDigit, awayDigit: newBetAwayDigit)){
                ModalService.showError(title: "Sorry", message: "That bet is already taken.")
            }else{
                //Prompt user's bet before submitting.
                let title: String = "Place Bet"
                let message: String = "You are betting that the " + homeTeam!.name + " score will end with " + String(describing: newBetHomeDigit) + ", and the " + awayTeam!.name + " score will end with " + String(describing: newBetAwayDigit) + ". This bet costs " + String(format: "$%.02f", betCost)

                ModalService.showConfirm(title: title, message: message, confirmText: "Confirm", cancelText: "Cancel")
                    .then{() -> Void in
                        SwiftSpinner.show("Placing Bet...")
                        //Create bet.
                        let bet: Bet = Bet()
                        bet.userId = SessionManager.getUserId()
                        bet.homeDigit = newBetHomeDigit
                        bet.awayDigit = newBetAwayDigit
                        
                        //Charge user account.
                        MyFirebaseRef.subtractCashToUser(userId: SessionManager.getUserId(), cashToSubtract: self.betCost)
                            .then{ () -> Void in
                                MyFirebaseRef.createNewBet(gameId: self.game.id, bet: bet)
                                    .then{ (betId) -> Void in
                                        self.getGame()
                                        ModalService.showSuccess(title: "Success", message: "Your bet has been placed.")
                                    }.catch{ (error) in
                                        ModalService.showError(title: "Error", message: error.localizedDescription)
                                    }.always{
                                        SwiftSpinner.hide()
                                }
                            }.catch{ (error) in
                                ModalService.showError(title: "Sorry", message: "You need more money to place this bet.")
                                SwiftSpinner.hide()
                            }.always {
                                
                            }
                    }.catch{ (error) in
                    }.always {
                }
            }
        }
    }
    
    @IBAction func homeDigitStepperAction(sender: UIStepper) {
        newBetHomeDigit.text = "\(Int(newBetHomeDigitStepper.value))"
    }
    
    @IBAction func awayDigitStepperAction(sender: UIStepper) {
        newBetAwayDigit.text = "\(Int(newBetAwayDigitStepper.value))"
    }
    
    func betTaken(homeDigit: Int, awayDigit: Int) -> Bool {
        for bet in bets {
            if(bet.homeDigit == homeDigit && bet.awayDigit == awayDigit){
                return true
            }
        }
        return false
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
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let profileViewController = storyBoard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        profileViewController.userId = selectedBet.userId
        self.navigationController!.pushViewController(profileViewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath) as? BetCell{
            
            let selectedBet: Bet = bets[indexPath.row]
            cell.userName.text = selectedBet.user.userName
            cell.userImage.kf.setImage(with: URL(string: selectedBet.user.imageDownloadUrl))
            cell.userImage.round(1, UIColor.black)
            cell.homeTeamImage.kf.setImage(with: URL(string: homeTeam!.imageDownloadUrl))
            cell.homeTeamImage.round(1, UIColor.black)
            cell.homeTeamDigit.text = String(describing: selectedBet.homeDigit!)
            cell.awayTeamImage.kf.setImage(with: URL(string: awayTeam!.imageDownloadUrl))
            cell.awayTeamImage.round(1, UIColor.black)
            cell.awayTeamDigit.text = String(describing: selectedBet.awayDigit!)
            
            let postDateTime: Date = ConversionService.getDateInTimeZone(date: selectedBet.postDateTime, timeZoneOffset: selectedBet.timeZoneOffSet)
            cell.posted.text = ConversionService.timeAgoSinceDate(date: postDateTime)
            
            return cell
        }
        fatalError("Unable to Dequeue Reusable Cell View")
    }
    
}


