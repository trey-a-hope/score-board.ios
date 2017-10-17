import Firebase
import PromiseKit
import SafariServices
import UIKit

class FullGameViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    
    //Info
    @IBOutlet weak var homeTeamImage: UIImageView!
    @IBOutlet weak var homeTeamView: UIView!
    @IBOutlet weak var homeTeamCity: UILabel!
    @IBOutlet weak var homeTeamName: UILabel!
    @IBOutlet weak var homeTeamPreDigit: UILabel!
    @IBOutlet weak var homeTeamPostDigit: UILabel!
    @IBOutlet weak var awayTeamImage: UIImageView!
    @IBOutlet weak var awayTeamView: UIView!
    @IBOutlet weak var awayTeamCity: UILabel!
    @IBOutlet weak var awayTeamName: UILabel!
    @IBOutlet weak var awayTeamPreDigit: UILabel!
    @IBOutlet weak var awayTeamPostDigit: UILabel!
    
    //Current Bets
    @IBOutlet weak var gameOwnerUserName: UILabel!
    @IBOutlet weak var gameOwnerImage: UIImageView!
    @IBOutlet weak var startDateTime: UILabel!
    @IBOutlet weak var totalBetCount: UILabel!
    @IBOutlet weak var yourBetCount: UILabel!
    @IBOutlet weak var potAmount: UILabel!
    @IBOutlet weak var status: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //Place New Bet
    @IBOutlet weak var betCostLabel: UILabel!
    @IBOutlet weak var newBetHomeTeamImage: UIImageView!
    @IBOutlet weak var newBetAwayTeamImage: UIImageView!
    @IBOutlet weak var newBetAwayDigitStepper: UIStepper!
    @IBOutlet weak var newBetHomeDigitStepper: UIStepper!
    @IBOutlet weak var newBetHomeDigit: UILabel!
    @IBOutlet weak var newBetAwayDigit: UILabel!
    @IBOutlet weak var submitBtn: UIButton!
    
    //Navbar buttons
    var shareButton: UIBarButtonItem!
    
    var gameId: String!
    var gameOwner: User!
    var homeTeam: NBATeam!
    var awayTeam: NBATeam!
    var game: Game!
    var bets: [Bet] = [Bet]()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(FullGameViewController.getGame), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        getGame()
    }
    
    func initUI() -> Void {
        //Configure bet collection view.
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib.init(nibName: "BetCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        
        gameOwnerImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToGameOwnerProfile)))
        gameOwnerImage.isUserInteractionEnabled = true
        
        //Share Button
        shareButton = UIBarButtonItem(
            title: "Share",
            style: .plain,
            target: self,
            action: #selector(FullGameViewController.share)
        )
        shareButton.setTitleTextAttributes(Constants.FONT_AWESOME_ATTRIBUTES, for: .normal)
        shareButton.title = String.fontAwesomeIcon(name: .shareAlt)
        shareButton.tintColor = .white
        
        //Add buttons to nav bar
        navigationItem.setRightBarButtonItems([shareButton], animated: false)
    }
    
    @objc func getGame() -> Void {
        //Fetch the game and bets for this game
        when(fulfilled: MyFSRef.getGame(gameId: gameId), MyFSRef.getBetsForGame(gameId: gameId))
            .then{ (result) -> Void in

                self.game = result.0
                self.bets = result.1
                
                //Get owner of this game
                MyFSRef.getUserById(id: self.game.userId)
                    .then{ (user) -> Void in
                        self.gameOwner = user
                        
                        //Set home team and away team
                        self.homeTeam = NBATeamService.instance.teams.filter({ $0.id == self.game.homeTeamId }).first!
                        self.awayTeam = NBATeamService.instance.teams.filter({ $0.id == self.game.awayTeamId }).first!
                        
                        //Set a user to each bet
                        if(self.bets.isEmpty){
                            self.setUI()
                        }else{
                            var betCount: Int = 0
                            for bet in self.bets {
                                MyFSRef.getUserById(id: bet.userId)
                                    .then{ (user) -> Void in
                                        bet.user = user
                                    }.always{
                                        betCount += 1
                                        if(betCount == self.bets.count){
                                            self.setUI()
                                        }
                                }
                            }
                        }
                    }.always{}
                

            }.always{}
    }
    
    func setUI() -> Void {
        //Home Team Info
        homeTeamPreDigit.text = String(describing: game.homeTeamScore / 10)
        homeTeamPostDigit.text = String(describing: game.homeTeamScore % 10)
        homeTeamImage.round(borderWidth: 0, borderColor: UIColor.black)
        homeTeamImage.kf.setImage(with: URL(string: homeTeam!.imageDownloadUrl))
        newBetHomeTeamImage.round(borderWidth: 0, borderColor: UIColor.black)
        newBetHomeTeamImage.kf.setImage(with: URL(string: homeTeam!.imageDownloadUrl))
        homeTeamCity.text = "Home - " + homeTeam!.city
        homeTeamName.text = homeTeam!.name
        homeTeamView.backgroundColor = homeTeam!.backgroundColor
        
        //Away Team Info
        awayTeamPreDigit.text = String(describing: game.awayTeamScore / 10)
        awayTeamPostDigit.text = String(describing: game.awayTeamScore % 10)
        awayTeamImage.round(borderWidth: 0, borderColor: UIColor.black)
        awayTeamImage.kf.setImage(with: URL(string: (awayTeam!.imageDownloadUrl)!))
        newBetAwayTeamImage.round(borderWidth: 0, borderColor: UIColor.black)
        newBetAwayTeamImage.kf.setImage(with: URL(string: awayTeam!.imageDownloadUrl))
        awayTeamCity.text = "Away - " + awayTeam!.city
        awayTeamName.text = awayTeam!.name
        awayTeamView.backgroundColor = awayTeam!.backgroundColor
        
        //Game owner
        gameOwnerImage.round(borderWidth: 0, borderColor: UIColor.black)
        gameOwnerImage.kf.setImage(with: URL(string: gameOwner.imageDownloadUrl))
        gameOwnerUserName.text = game.userId == SessionManager.getUserId() ? "You" : gameOwner.userName

        //Start date and time
        let d: Date = ConversionService.getDateInTimeZone(date: game.startDateTime, timeZoneOffset: game.startTimeZoneOffSet)
        startDateTime.text = ConversionService.convertDateToDateAtTimeString(date: d)
        switch(Date().getTimeZoneOffset()){
            case 240:
                if(ConversionService.isDaylightSavingTime()){
                    startDateTime.text = startDateTime.text! + " EDT"
                }else{
                    
                }
                break
            case 300:
                if(ConversionService.isDaylightSavingTime()){
                    startDateTime.text = startDateTime.text! + " CDT"
                }else{
                    startDateTime.text = startDateTime.text! + " EST"
                }
                break
            case 360:
                if(ConversionService.isDaylightSavingTime()){
                    startDateTime.text = startDateTime.text! + " MDT"
                }else{
                    startDateTime.text = startDateTime.text! + " CST"
                }
                break
            case 420:
                if(ConversionService.isDaylightSavingTime()){
                    startDateTime.text = startDateTime.text! + " PDT"
                }else{
                    startDateTime.text = startDateTime.text! + " MST"
                }
                break
            case 480:
                if(ConversionService.isDaylightSavingTime()){
                    
                }else{
                    startDateTime.text = startDateTime.text! + " PST"
                }
                break
            default:break
        }
        
        //Sort Bets by time
        bets = bets.sorted(by: { $0.postDateTime > $1.postDateTime })
        
        //Track number of bet the user has
        var numberOfBetUserHas: Int = 0
        for bet in bets{
            if(bet.userId == SessionManager.getUserId()){
                numberOfBetUserHas += 1
            }
            
            //Bring the winning bet to the front of the list.
            if(isWinningBet(bet: bet)){
                //Remove bet from list.
                bets = bets.filter { $0.id != bet.id }
                //Then place in front.
                bets.insert(bet, at: 0)
            }
        }
        
        //Set Bet Cost
        betCostLabel.text = String(format: "$%.02f", game.betPrice)
        
        //Set total bet count.
        totalBetCount.text = String(describing: bets.count)
        
        //Set number of bet user has.
        yourBetCount.text = String(describing: numberOfBetUserHas)
        
        //Set pot amount
        potAmount.text = String(format: "$%.02f", game.potAmount)
        
        //Set status of game, (Pre, Active, or Post)
        switch(game.activeCode){
            case 0:
                status.text = "Pre"
                break
            case 1:
                status.text = "Active"
                break
            case 2:
                status.text = "Post"
                break
            default:break
        }
        
        //Refresh table of bets.
        collectionView.reloadData()
    }
    
    @objc func goToGameOwnerProfile() -> Void {
        let profileViewController = storyBoard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        profileViewController.userId = game.userId
        navigationController!.pushViewController(profileViewController, animated: true)
    }
    
    @objc func share() -> Void {
        let textToShare = "Check out this game I'm betting on in ScorBord!"
        if let myWebsite = NSURL(string: "www.google.com") {
            let objectsToShare = [textToShare, myWebsite] as [Any]
            let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            present(activityViewController, animated: true, completion: nil)
        }else{
            //TODO: DISPLAY MODAL SAYING LINK IS MALFORMED
        }
    }
    
    @IBAction func submitAction(_ sender: UIButton) {
        if(game.userId == SessionManager.getUserId()){
            ModalService.showError(title: "Sorry", message: "You can only place bets on games you do not own.")
        }
        else if(game.activeCode == 2){
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
                let message: String = "You are betting that the " + homeTeam!.name + " score will end with " + String(describing: newBetHomeDigit) + ", and the " + awayTeam!.name + " score will end with " + String(describing: newBetAwayDigit) + ". " + String(format: "$%.02f", game.betPrice) + " will be charged to your card."

                ModalService.showConfirm(title: title, message: message, confirmText: "Confirm", cancelText: "Cancel")
                    .then{() -> Void in
                        
                        //Create bet.
                        let bet: Bet = Bet()
                        bet.userId = SessionManager.getUserId()
                        bet.gameId = self.gameId
                        bet.homeTeamId = self.homeTeam.id
                        bet.awayTeamId = self.awayTeam.id
                        bet.homeDigit = newBetHomeDigit
                        bet.awayDigit = newBetAwayDigit
                        
                        //TODO: Charge user account with Stripe.
                        MyFSRef.createBet(bet: bet)
                            .then{ (betId) -> Void in
                                self.getGame()
                                ModalService.showSuccess(title: "Success", message: "Your bet has been placed.")
                            }.always{}
                    }.always {}
            }
        }
    }
    
    @IBAction func homeDigitStepperAction(sender: UIStepper) {
        if(game.userId == SessionManager.getUserId()){
            ModalService.showError(title: "Sorry", message: "You can only place bets on games you do not own.")
        }else if(game.activeCode == 2){
            ModalService.showError(title: "Game Has Ended", message: "You can only bet on 'Pre' games.")
        }else if(game.activeCode == 1){
            ModalService.showError(title: "Game Is In Progress", message: "You can only bet on 'Pre' games.")
        }else{
            newBetHomeDigit.text = "\(Int(newBetHomeDigitStepper.value))"
        }
    }
    
    @IBAction func awayDigitStepperAction(sender: UIStepper) {
        if(game.userId == SessionManager.getUserId()){
            ModalService.showError(title: "Sorry", message: "You can only place bets on games you do not own.")
        }else if(game.activeCode == 2){
            ModalService.showError(title: "Game Has Ended", message: "You can only bet on 'Pre' games.")
        }else if(game.activeCode == 1){
            ModalService.showError(title: "Game Is In Progress", message: "You can only bet on 'Pre' games.")
        }else{
            newBetAwayDigit.text = "\(Int(newBetAwayDigitStepper.value))"
        }
    }
    
    //Return true if the bet is already occupied
    func betTaken(homeDigit: Int, awayDigit: Int) -> Bool {
        for bet in bets {
            if(bet.homeDigit == homeDigit && bet.awayDigit == awayDigit){
                return true
            }
        }
        return false
    }
    
    //Determines if this bet reflects the current score
    func isWinningBet(bet: Bet) -> Bool {
        if(Int(homeTeamPostDigit.text!)! == bet.homeDigit && Int(awayTeamPostDigit.text!)! == bet.awayDigit){
            return true
        }
        return false
    }

}

extension FullGameViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    //Child section dimensions
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //NOTE: Height here should always equal height in XIB file.
        return CGSize(width: CGFloat(175), height: collectionView.bounds.height)
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
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let bet: Bet = bets[indexPath.row]
        let profileViewController = storyBoard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        
        
        profileViewController.userId = bet.userId
        self.navigationController!.pushViewController(profileViewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? BetCell{
            
            let selectedBet: Bet = bets[indexPath.row]
            
            //If the current score is this bet, add yellow tint to background
            if(isWinningBet(bet: selectedBet)){
                cell.view.backgroundColor = GMColor.amber100Color()
            }else{
                cell.view.backgroundColor = GMColor.grey100Color()
            }
            
            cell.userName.text = selectedBet.user.userName
            cell.userImage.kf.setImage(with: URL(string: selectedBet.user.imageDownloadUrl))
            cell.userImage.round(borderWidth: 1, borderColor: UIColor.black)
            cell.homeTeamImage.kf.setImage(with: URL(string: homeTeam!.imageDownloadUrl))
            cell.homeTeamImage.round(borderWidth: 1, borderColor: UIColor.black)
            cell.homeTeamDigit.text = String(describing: selectedBet.homeDigit!)
            cell.awayTeamImage.kf.setImage(with: URL(string: awayTeam!.imageDownloadUrl))
            cell.awayTeamImage.round(borderWidth: 1, borderColor: UIColor.black)
            cell.awayTeamDigit.text = String(describing: selectedBet.awayDigit!)
            let postDateTime: Date = ConversionService.getDateInTimeZone(date: selectedBet.postDateTime, timeZoneOffset: selectedBet.postTimeZoneOffSet)
            cell.posted.text = ConversionService.timeAgoSinceDate(date: postDateTime)
            
            return cell
        }
        fatalError("Unable to Dequeue Reusable Cell View")
    }
}

extension FullGameViewController : SFSafariViewControllerDelegate {
    func openUrl(url: String) -> Void {
        let svc = SFSafariViewController(url: NSURL(string: url)! as URL)
        svc.delegate = self
        svc.preferredBarTintColor = .red
        svc.preferredControlTintColor = .white
        present(svc, animated: true, completion: nil)
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) -> Void {
        controller.dismiss(animated: true, completion: nil)
    }
}

