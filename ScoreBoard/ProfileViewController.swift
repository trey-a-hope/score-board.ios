import Firebase
import FontAwesome_swift
import Foundation
import Material
import PromiseKit
import Kingfisher
import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var gamesWonLabel: UILabel!
    @IBOutlet weak var betsWonLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var myBetsLabel: UILabel!
    @IBOutlet weak var myGamesLabel: UILabel!
    @IBOutlet weak var myBetsCollectionView: UICollectionView!
    @IBOutlet weak var myGamesCollectionView: UICollectionView!
    
    //Navbar buttons
    var messagesButton: UIBarButtonItem!
    var editProfileButton: UIBarButtonItem!
    var adminButton: UIBarButtonItem!

    let imagePicker = UIImagePickerController()
    let BetCellWidth: CGFloat = CGFloat(175)
    let CellIdentifier: String = "Cell"
    var userId: String?
    var user: User?
    var myBets: [BetView] = [BetView]()
    var myGames: [Game] = [Game]()
    
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ProfileViewController.getUser), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        getUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Display navbar on return from image picker.
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        //Set page title to username
        navigationController?.visibleViewController?.navigationItem.titleView = nil
        navigationController?.visibleViewController?.title = "Profile"
        
        //If currently viewing your own profile, add "edit profile" and "message" buttons.
        if(userId == SessionManager.getUserId()){
            navigationController?.visibleViewController?.navigationItem.setRightBarButtonItems([messagesButton, editProfileButton, adminButton], animated: true)
        }
        //Else, add only message button to message user.
        else{
            navigationController?.visibleViewController?.navigationItem.setRightBarButtonItems([messagesButton], animated: true)
        }
        
        getUser()
    }

    func initUI() -> Void {
        //Configure imagepicker.
        imagePicker.delegate = self
        
        //Add refresh control.
        scrollView.addSubview(self.refreshControl)
        
        //Configure my bets collection view
        myBetsCollectionView.dataSource = self
        myBetsCollectionView.delegate = self
        myBetsCollectionView.register(UINib.init(nibName: "BetCell", bundle: nil), forCellWithReuseIdentifier: CellIdentifier)
        myGamesCollectionView.dataSource = self
        myGamesCollectionView.delegate = self
        myGamesCollectionView.register(UINib.init(nibName: "GameCell", bundle: nil), forCellWithReuseIdentifier: CellIdentifier)
        
        //Configure profile imageview.
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(updateProfilePicture)))
        profileImage.isUserInteractionEnabled = true
        
        //Messages Button
        messagesButton = UIBarButtonItem(
            title: "Add",
            style: .plain,
            target: self,
            action: #selector(ProfileViewController.openMessages)
        )
        messagesButton.setTitleTextAttributes(Constants.FONT_AWESOME_ATTRIBUTES, for: .normal)
        messagesButton.title = String.fontAwesomeIcon(name: .envelope)
        messagesButton.tintColor = .white
        
        //Edit Profile Button
        editProfileButton = UIBarButtonItem(
            title: "Add",
            style: .plain,
            target: self,
            action: #selector(ProfileViewController.openEditProfile)
        )
        editProfileButton.setTitleTextAttributes(Constants.FONT_AWESOME_ATTRIBUTES, for: .normal)
        editProfileButton.title = String.fontAwesomeIcon(name: .pencil)
        editProfileButton.tintColor = .white
        
        //Admin Button
        adminButton = UIBarButtonItem(
            title: "Add",
            style: .plain,
            target: self,
            action: #selector(ProfileViewController.openAdmin)
        )
        adminButton.setTitleTextAttributes(Constants.FONT_AWESOME_ATTRIBUTES, for: .normal)
        adminButton.title = String.fontAwesomeIcon(name: .cogs)
        adminButton.tintColor = .white
    }
    
    func getUser() -> Void {
        //If viewing another person's profile, user their userId. Otherwise, use yours.
        if let _ = userId {}
        else{userId = SessionManager.getUserId()}
                
        MyFSRef.getUserById(id: userId!)
            .then{ (user) -> Void in
                self.user = user
                self.getBets()
            }.always{}
    }
    
    func getBets() -> Void {        
        MyFSRef.getGames()
            .then{ (games) -> Void in
                //Clear bets and games
                self.myBets.removeAll()
                self.myGames.removeAll()
                
                for game in games {
                    //Determine which bets are mine
                    for bet in game.bets {
                        if(bet.userId == self.userId){
                            self.myBets.append(
                                BetView(
                                    homeTeam: NBATeamService.instance.getTeam(id: game.homeTeamId ),
                                    awayTeam: NBATeamService.instance.getTeam(id: game.awayTeamId ),
                                    bet: bet,
                                    gameId: game.id)
                                )
                        }
                    }
                    //Determine which games are mine
                    if(game.userId == self.userId){
                        self.myGames.append(game)
                    }
                }
                
                //Sort Bets by time.
                self.myBets = self.myBets.sorted(by: { $0.bet.postDateTime > $1.bet.postDateTime })
                self.setUI()
            }.always{
                self.myBetsCollectionView.reloadData()
                self.myGamesCollectionView.reloadData()
                self.refreshControl.endRefreshing()
        }
    }
    
    func setUI() -> Void {
        //Profile image
        profileImage.round(borderWidth: 8.0, borderColor: UIColor.white)
        profileImage.kf.setImage(with: URL(string: user!.imageDownloadUrl))
        
        //Location
        if let _ = user!.city, let _ = user!.stateId {
            locationLabel.text = user!.city + ", " + StateService.getStateAbbreviation(user!.stateId)
        }else{
            locationLabel.text = "No location"
        }
        
        //Username
        userNameLabel.text = user!.userName
        
        //Points
        pointsLabel.text = String(describing: user!.points!)
        
        //Games won
        gamesWonLabel.text = String(describing: user!.gamesWon!)
        
        //Bets won
        betsWonLabel.text = String(describing: user!.betsWon!)
        
        //My bets label, gender specific
        if(userId == SessionManager.getUserId()){
            myBetsLabel.text = "My bets - "
        }else{
            if let _ = user!.gender {
                myBetsLabel.text = user!.gender == "F" ? "Her bets - " : "His bets - "
            }else{
                myBetsLabel.text = "Their bets - "
            }
        }
        myBetsLabel.text = myBetsLabel.text! + String(describing: myBets.count)
        
        //My games label, gender specific
        if(userId == SessionManager.getUserId()){
            myGamesLabel.text = "My games - "
        }else{
            if let _ = user!.gender {
                myGamesLabel.text = user!.gender == "F" ? "Her games - " : "His games - "
            }else{
                myGamesLabel.text = "Their games - "
            }
        }
        myGamesLabel.text = myGamesLabel.text! + String(describing: myGames.count)
    }
    
    func openAdmin() -> Void {
        let adminTableViewController = storyBoard.instantiateViewController(withIdentifier: "AdminTableViewController") as! AdminTableViewController
        navigationController?.pushViewController(adminTableViewController, animated: true)
    }
    
    func openEditProfile() -> Void {
        let editProfileViewController = storyBoard.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
        navigationController?.pushViewController(editProfileViewController, animated: true)
    }
    
    func openMessages() -> Void {
        //If current user, navigate to list of message.
        if(userId == SessionManager.getUserId()){
            let messagesViewController = storyBoard.instantiateViewController(withIdentifier: "MessagesViewController") as! MessagesViewController
            navigationController?.pushViewController(messagesViewController, animated: true)
        }
            //Otherwise, open message view directly to message this user.
        else{
            ModalService.showInfo(title: "Message " + (self.user?.userName)!, message: "Coming soon...")
        }
    }
    
    func updateProfilePicture() -> Void {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }else{
            ModalService.showError(title: "Sorry", message: "Image Picker Not Available")
        }
    }
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    //Child section dimensions.
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //NOTE: Height here should always equal height in XIB file.
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
    //Collection View Data Source Methods.
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == myBetsCollectionView){
            return myBets.count
        }
        else if(collectionView == myGamesCollectionView){
            return myGames.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) -> Void {
        
        var gameId: String!
        
        if(collectionView == myBetsCollectionView){
            gameId = myBets[indexPath.row].gameId!
        }
        else if(collectionView == myGamesCollectionView){
            gameId = myGames[indexPath.row].id!
        }
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let fullGameViewController = storyBoard.instantiateViewController(withIdentifier: "FullGameViewController") as! FullGameViewController
        fullGameViewController.gameId = gameId
        self.navigationController?.pushViewController(fullGameViewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(collectionView == myBetsCollectionView){
            if let betCell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath) as? BetCell{
                
                let selectedBet: Bet = myBets[indexPath.row].bet!
                betCell.userName.text = self.user!.userName
                betCell.userImage.kf.setImage(with: URL(string: self.user!.imageDownloadUrl))
                betCell.userImage.round(borderWidth: 1, borderColor: UIColor.black)
                betCell.homeTeamImage.kf.setImage(with: URL(string: myBets[indexPath.row].homeTeam.imageDownloadUrl))
                betCell.homeTeamImage.round(borderWidth: 1, borderColor: UIColor.black)
                betCell.homeTeamDigit.text = String(describing: selectedBet.homeDigit!)
                betCell.awayTeamImage.kf.setImage(with: URL(string: myBets[indexPath.row].awayTeam.imageDownloadUrl))
                betCell.awayTeamImage.round(borderWidth: 1, borderColor: UIColor.black)
                betCell.awayTeamDigit.text = String(describing: selectedBet.awayDigit!)
                
                let d: Date = ConversionService.getDateInTimeZone(date: selectedBet.postDateTime, timeZoneOffset: selectedBet.postTimeZoneOffSet)
                betCell.posted.text = ConversionService.timeAgoSinceDate(date: d)
                
                return betCell
            }
            fatalError("Unable to Dequeue Reusable Cell View")
        }
        else if(collectionView == myGamesCollectionView){
            if let gameCell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath) as? GameCell{
                
                let selectedGame: Game = myGames[indexPath.row]

                let homeTeam: NBATeam = NBATeamService.instance.teams.filter({ $0.name == selectedGame.homeTeamName }).first!
                let awayTeam: NBATeam = NBATeamService.instance.teams.filter({ $0.name == selectedGame.awayTeamName }).first!
                
                gameCell.userName.text = self.user!.userName
                gameCell.homeTeamImage.kf.setImage(with: URL(string: homeTeam.imageDownloadUrl))
                gameCell.homeTeamImage.round(borderWidth: 1, borderColor: UIColor.black)
                gameCell.homeTeamScore.text = String(describing: selectedGame.homeTeamScore!)
                gameCell.awayTeamImage.kf.setImage(with: URL(string: awayTeam.imageDownloadUrl))
                gameCell.awayTeamImage.round(borderWidth: 1, borderColor: UIColor.black)
                gameCell.awayTeamScore.text = String(describing: selectedGame.awayTeamScore!)
                
//                let d: Date = ConversionService.getDateInTimeZone(date: selectedBet.postDateTime, timeZoneOffset: selectedBet.postTimeZoneOffSet)
                gameCell.taken.text = "TBA"
                
                return gameCell
            }
            fatalError("Unable to Dequeue Reusable Cell View")
        }
        
        return (collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath) as? GameCell)!
    }
}

extension ProfileViewController : UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) -> Void {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            dismiss(animated: true, completion: nil)
            let cropperViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CropperViewController") as! CropperViewController
            cropperViewController.image = image
            navigationController?.pushViewController(cropperViewController, animated: true)
        }else{
            picker.dismiss(animated: true, completion: nil);
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) -> Void {
        picker.dismiss(animated: true, completion: nil)
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
