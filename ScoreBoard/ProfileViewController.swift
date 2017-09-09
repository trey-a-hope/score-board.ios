import Firebase
import FirebaseDatabase
import FontAwesome_swift
import Foundation
import Material
import PopupDialog
import Kingfisher
import SwiftSpinner
import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var chipsLabel: UILabel!
    @IBOutlet weak var currentBetsLabel: UILabel!
    @IBOutlet weak var betsWonLabel: UILabel!
    
    let BetCellWidth: CGFloat = CGFloat(175)
    let CellIdentifier: String = "Cell"
    var userId: String?
    private var user: User?
    fileprivate var myBets: [BetView] = [BetView]()
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ProfileViewController.getUser), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(ConnectionManager.isConnectedToInternet()){
            initUI()
            getUser()
        }else{
            ModalService.showError(title: "Error", message: "No internet connection.")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.visibleViewController?.title = "Profile"
        
        //If currently viewing your own profile, add "edit profile" and "message" buttons.
        if(userId == SessionManager.getUserId()){
            setNavBarButtons()
        }
    }

    func initUI() -> Void {
        self.scrollView.addSubview(self.refreshControl)
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        let XIBCell = UINib.init(nibName: "BetCell", bundle: nil)
        collectionView.register(XIBCell, forCellWithReuseIdentifier: CellIdentifier)
        
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(updateProfilePicture)))
        profileImage.isUserInteractionEnabled = true
    }
    
    func getUser() -> Void {
        //If viewing another person's profile.
        if let _ = userId {}
        else{
            userId = SessionManager.getUserId()
        }
        
        SwiftSpinner.show("Loading...")
        MyFirebaseRef.getUserByID(id: userId!)
            .then{ (user) -> Void in
                
                self.user = user
                self.getMyBets()
                
            }.catch{ (error) in
                
            }.always{
                SwiftSpinner.hide()
            }
    }
    
    func getMyBets() -> Void {
        SwiftSpinner.show("Getting bets...")
        MyFirebaseRef.getGames()
            .then{ (gameBundles) -> Void in
                
                //Clear bets.
                self.myBets.removeAll()
                
                //Determine which bets are mines.
                for gameBundle in gameBundles {
                    for bet in gameBundle.bets {
                        if(bet.userId == self.userId){
                            self.myBets.append(
                                BetView(
                                    homeTeam: NBATeamService.instance.getTeam(id: gameBundle.game.homeTeamId ),
                                    awayTeam: NBATeamService.instance.getTeam(id: gameBundle.game.awayTeamId ),
                                    bet: bet,
                                    gameId: gameBundle.game.id)
                                )
                        }
                    }
                }
                
                //Sort Bets by time.
                self.myBets = self.myBets.sorted(by: { $0.bet.postDateTime > $1.bet.postDateTime })
                
                self.setUI()
                
            }.catch{ (error) in
                
            }.always{
                
                self.collectionView.reloadData()
                self.refreshControl.endRefreshing()
                SwiftSpinner.hide()
                
        }
    }
    
    func editProfile() -> Void {
        ModalService.showInfo(title: "Edit Profile", message: "Coming Soon")
    }
    
    func messages() -> Void {
        ModalService.showInfo(title: "Messages", message: "Coming Soon")
    }
    
    func updateProfilePicture() -> Void {
        ModalService.showInfo(title: "Update Profile Image", message: "Coming Soon")
    }
    
    func setUI() -> Void {
        setUserName()
        setProfileImage()
        setChips()
        setCurrentBets()
        setBetsWon()
    }
    
    func setNavBarButtons() -> Void {
        /* Edit Profile Button */
        let editProfileButton = UIBarButtonItem(
            title: "Add",
            style: .plain,
            target: self,
            action: #selector(ProfileViewController.editProfile)
        )
        editProfileButton.setTitleTextAttributes(Constants.FONT_AWESOME_ATTRIBUTES, for: .normal)
        editProfileButton.title = String.fontAwesomeIcon(name: .pencil)
        editProfileButton.tintColor = .white
        /* Messages Button */
        let messagesButton = UIBarButtonItem(
            title: "Add",
            style: .plain,
            target: self,
            action: #selector(ProfileViewController.messages)
        )
        messagesButton.setTitleTextAttributes(Constants.FONT_AWESOME_ATTRIBUTES, for: .normal)
        messagesButton.title = String.fontAwesomeIcon(name: .envelope)
        messagesButton.tintColor = .white
        /* Apply buttons to navbar. */
        self.navigationController?.visibleViewController?.navigationItem.setRightBarButtonItems([messagesButton, editProfileButton], animated: true)
    }

    func setUserName() -> Void {
        if let _ = user!.userName {
            userNameLabel.text = user!.userName
        }else{
            chipsLabel.text = "User Name Not Set"
        }
    }
    
    func setProfileImage() -> Void {
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2;
        profileImage.clipsToBounds = true;
        profileImage.layer.borderWidth = 2.0
        profileImage.layer.borderColor = UIColor.white.cgColor
        //profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileImageClick)))
        profileImage.isUserInteractionEnabled = true
        if let imageDownloadUrl = user!.imageDownloadUrl {
            profileImage.kf.setImage(with: URL(string: imageDownloadUrl))
        }else{
            //TODO: Display empty grey box.
        }
    }
    
    func setChips() -> Void {
        if let _ = user!.chips {
            chipsLabel.text = user!.chips.withCommas()
        }else{
            chipsLabel.text = "0"
        }
    }
    
    func setCurrentBets() -> Void {
        currentBetsLabel.text = String(describing: myBets.count)
    }
    
    func setBetsWon() -> Void {
        betsWonLabel.text = "6"
    }
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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

extension ProfileViewController: UICollectionViewDataSource {
    /* Collection View Data Source Methods. */
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myBets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let fullGameViewController = storyBoard.instantiateViewController(withIdentifier: "FullGameViewController") as! FullGameViewController
        fullGameViewController.gameId = myBets[indexPath.row].gameId!
        self.navigationController?.pushViewController(fullGameViewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath) as? BetCell{
            
            let selectedBet: Bet = myBets[indexPath.row].bet!
            cell.userName.text = selectedBet.userName
            cell.userImage.kf.setImage(with: URL(string: selectedBet.userImageDownloadUrl))
            cell.userImage.round(1, UIColor.black)
            cell.homeTeamImage.kf.setImage(with: URL(string: myBets[indexPath.row].homeTeam.imageDownloadUrl))
            cell.homeTeamImage.round(1, UIColor.black)
            cell.homeTeamDigit.text = String(describing: selectedBet.homeDigit!)
            cell.awayTeamImage.kf.setImage(with: URL(string: myBets[indexPath.row].awayTeam.imageDownloadUrl))
            cell.awayTeamImage.round(1, UIColor.black)
            cell.awayTeamDigit.text = String(describing: selectedBet.awayDigit!)
            
            let d: Date = ConversionService.getDateInTimeZone(date: selectedBet.postDateTime, timeZoneOffset: selectedBet.timeZoneOffSet)
            cell.posted.text = ConversionService.timeAgoSinceDate(date: d)
            
            return cell
        }
        fatalError("Unable to Dequeue Reusable Cell View")
    }
    
}

//Custom view to hold home team and away team since there are multiple games bought back on this view.
class BetView {
    var homeTeam: NBATeam!
    var awayTeam: NBATeam!
    var bet: Bet!
    var gameId: String!
    
    init(homeTeam: NBATeam, awayTeam: NBATeam, bet: Bet, gameId: String){
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.bet = bet
        self.gameId = gameId
    }
}
