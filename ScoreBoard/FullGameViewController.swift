import Firebase
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
    @IBOutlet weak var startDateTime: UILabel!
    @IBOutlet weak var totalBetCount: UILabel!
    @IBOutlet weak var yourBetCount: UILabel!
    @IBOutlet weak var potAmount: UILabel!
    @IBOutlet weak var status: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
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
    
    //Navbar buttons
    var shareButton: UIBarButtonItem!
    
    var gameId: String!
    var homeTeam: NBATeam!
    var awayTeam: NBATeam!
    var game: Game = Game()
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    
    //Database reference to this game
    private var gameRef: DatabaseReference!
    //Handle that will track any data changes to this game
    private var gameUpdateRefHandle: DatabaseHandle?
    
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
        //Set bet collection view delegate and datasource.
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let XIBCell = UINib.init(nibName: "BetCell", bundle: nil)
        collectionView.register(XIBCell, forCellWithReuseIdentifier: "Cell")
        
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
        
        //Set database reference for this game.
        gameRef = Database.database().reference().child("Games").child(gameId)
    }
    
    func getGame() -> Void {
        //Watch for any changes to this game, (new bet added, status change, etc.)
        gameUpdateRefHandle = gameRef.observe(.value, with: { (gameSnapshot) -> Void in
            self.game = MyFirebaseRef.extractGameData(gameSnapshot: gameSnapshot)
            
            self.homeTeam = NBATeamService.instance.getTeam(id: self.game.homeTeamId)
            self.awayTeam = NBATeamService.instance.getTeam(id: self.game.awayTeamId)
            
            //Apply user object to each bet and refresh collection view.
            if(self.game.bets.isEmpty){
                self.setUI()
            }else{
                var betCount: Int = 0
                for bet in self.game.bets {
                    MyFirebaseRef.getUserByID(id: bet.userId)
                        .then{ (user) -> Void in
                            bet.user = user
                        }.always{
                            betCount += 1
                            if(betCount == self.game.bets.count){
                                self.collectionView.reloadData()
                                self.setUI()
                            }
                    }
                }
            }
        })
    }
    
    func setUI() -> Void {
        //Calculate bet cost (1 + ( 2 * numberOfBetUserHas) ).
        betCost = 1.00
        //Track number of bet the user has
        var numberOfBetUserHas: Int = 0
        
        for bet in game.bets{
            if(bet.userId == SessionManager.getUserId()){
                betCost += 2
                numberOfBetUserHas += 1
            }
        }
        //Set Bet Cost
        betCostLabel.text = String(format: "$%.02f", betCost)
        //Sort Bets by time.
        game.bets = game.bets.sorted(by: { $0.postDateTime > $1.postDateTime })
        
        //Refresh table of bets.
        collectionView.reloadData()

        //Home Team Digit
        homeTeamPreDigit.text = String(describing: game.homeTeamScore / 10)
        homeTeamPostDigit.text = String(describing: game.homeTeamScore % 10)
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
        awayTeamPreDigit.text = String(describing: game.awayTeamScore / 10)
        awayTeamPostDigit.text = String(describing: game.awayTeamScore % 10)
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

        //Set start date for game.
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
        
        //Set total bet count.
        totalBetCount.text = String(describing: game.bets.count)
        
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
                                    }.always{}
                            }.always {}
                    }.always {}
            }
        }
    }
    
    @IBAction func homeDigitStepperAction(sender: UIStepper) {
        newBetHomeDigit.text = "\(Int(newBetHomeDigitStepper.value))"
    }
    
    @IBAction func awayDigitStepperAction(sender: UIStepper) {
        newBetAwayDigit.text = "\(Int(newBetAwayDigitStepper.value))"
    }
    
    //Return true if the bet is already occupied.
    func betTaken(homeDigit: Int, awayDigit: Int) -> Bool {
        for bet in game.bets {
            if(bet.homeDigit == homeDigit && bet.awayDigit == awayDigit){
                return true
            }
        }
        return false
    }
    
    deinit {
        if let refHandle = gameUpdateRefHandle {
            gameRef.removeObserver(withHandle: refHandle)
        }
    }
}

extension FullGameViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    //Child section dimensions.
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
    //Collection View Data Source Methods.
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return game.bets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedBet: Bet = game.bets[indexPath.row]
        let profileViewController = storyBoard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        profileViewController.userId = selectedBet.userId
        self.navigationController!.pushViewController(profileViewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? BetCell{
            
            let selectedBet: Bet = game.bets[indexPath.row]
            
            //If the current score is this bet, add yellow tint to background
            if(Int(homeTeamPostDigit.text!)! == selectedBet.homeDigit && Int(awayTeamPostDigit.text!)! == selectedBet.awayDigit){
                cell.view.backgroundColor = GMColor.amber100Color()
            }else{
                cell.view.backgroundColor = GMColor.grey100Color()
            }
            
            cell.userName.text = selectedBet.user.userName
            cell.userImage.kf.setImage(with: URL(string: selectedBet.user.imageDownloadUrl))
            cell.userImage.round(1, UIColor.black)
            cell.homeTeamImage.kf.setImage(with: URL(string: homeTeam!.imageDownloadUrl))
            cell.homeTeamImage.round(1, UIColor.black)
            cell.homeTeamDigit.text = String(describing: selectedBet.homeDigit!)
            cell.awayTeamImage.kf.setImage(with: URL(string: awayTeam!.imageDownloadUrl))
            cell.awayTeamImage.round(1, UIColor.black)
            cell.awayTeamDigit.text = String(describing: selectedBet.awayDigit!)
            let postDateTime: Date = ConversionService.getDateInTimeZone(date: selectedBet.postDateTime, timeZoneOffset: selectedBet.postTimeZoneOffSet)
            cell.posted.text = ConversionService.timeAgoSinceDate(date: postDateTime)
            
            return cell
        }
        fatalError("Unable to Dequeue Reusable Cell View")
    }
    
}


