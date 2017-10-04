import Firebase
import FirebaseDatabase
import FontAwesome_swift
import Foundation
import Material
import PromiseKit
import Kingfisher
import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var currentBetsLabel: UILabel!
    @IBOutlet weak var betsWonLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var myBetsLabel: UILabel!
    
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
    
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    
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
        
        //Configure collection view.
        collectionView.dataSource = self
        collectionView.delegate = self
        let XIBCell = UINib.init(nibName: "BetCell", bundle: nil)
        collectionView.register(XIBCell, forCellWithReuseIdentifier: CellIdentifier)
        
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
        
        MyFirebaseRef.getUserByID(id: userId!)
            .then{ (user) -> Void in
                self.user = user
                self.getBets()
            }.always{}
    }
    
    func getBets() -> Void {
        MyFirebaseRef.getGames()
            .then{ (games) -> Void in
                //Clear bets.
                self.myBets.removeAll()
                
                //Determine which bets are mines.
                for game in games {
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
                }
                
                //Sort Bets by time.
                self.myBets = self.myBets.sorted(by: { $0.bet.postDateTime > $1.bet.postDateTime })
                self.setUI()
            }.always{
                self.collectionView.reloadData()
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
        
        //Current bets amount
        currentBetsLabel.text = String(describing: myBets.count)
        
        //Bets won
        betsWonLabel.text = String(describing: user!.betsWon!)
        
        //My bets label, gender specific
        if(userId == SessionManager.getUserId()){
            myBetsLabel.text = "My bets"
        }else{
            if let _ = user!.gender {
                myBetsLabel.text = user!.gender == "F" ? "Her bets" : "His bets"
            }else{
                myBetsLabel.text = "Their bets"
            }
        }
    }
    
    func openAdmin() -> Void {
        let adminViewController = storyBoard.instantiateViewController(withIdentifier: "AdminViewController") as! AdminViewController
        navigationController?.pushViewController(adminViewController, animated: true)
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
            cell.userName.text = self.user!.userName
            cell.userImage.kf.setImage(with: URL(string: self.user!.imageDownloadUrl))
            cell.userImage.round(borderWidth: 1, borderColor: UIColor.black)
            cell.homeTeamImage.kf.setImage(with: URL(string: myBets[indexPath.row].homeTeam.imageDownloadUrl))
            cell.homeTeamImage.round(borderWidth: 1, borderColor: UIColor.black)
            cell.homeTeamDigit.text = String(describing: selectedBet.homeDigit!)
            cell.awayTeamImage.kf.setImage(with: URL(string: myBets[indexPath.row].awayTeam.imageDownloadUrl))
            cell.awayTeamImage.round(borderWidth: 1, borderColor: UIColor.black)
            cell.awayTeamDigit.text = String(describing: selectedBet.awayDigit!)
            
            let d: Date = ConversionService.getDateInTimeZone(date: selectedBet.postDateTime, timeZoneOffset: selectedBet.postTimeZoneOffSet)
            cell.posted.text = ConversionService.timeAgoSinceDate(date: d)
            
            return cell
        }
        fatalError("Unable to Dequeue Reusable Cell View")
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
