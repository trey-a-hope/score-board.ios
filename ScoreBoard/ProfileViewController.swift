import Firebase
import FirebaseDatabase
import FontAwesome_swift
import Foundation
import Material
import PopupDialog
import PromiseKit
import Kingfisher
import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var cashLabel: UILabel!
    @IBOutlet weak var currentBetsLabel: UILabel!
    @IBOutlet weak var betsWonLabel: UILabel!
    
    //Navbar buttons
    var messagesButton: UIBarButtonItem!
    var editProfileButton: UIBarButtonItem!
    var addCashButton: UIBarButtonItem!
    
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
        
        navigationController?.visibleViewController?.title = "Profile"
        
        //If currently viewing your own profile, add "edit profile" and "message" buttons.
        if(userId == SessionManager.getUserId()){
            setNavBarButtons()
        }
        
        getUser()
    }

    func initUI() -> Void {
        //Configure imagepicker.
        imagePicker.delegate = self
        
        //Add refresh control.
        self.scrollView.addSubview(self.refreshControl)
        
        //Configure collection view.
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
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
        
        //Add Cash Button
        addCashButton = UIBarButtonItem(
            title: "Add",
            style: .plain,
            target: self,
            action: #selector(ProfileViewController.addCash)
        )
        addCashButton.setTitleTextAttributes(Constants.FONT_AWESOME_ATTRIBUTES, for: .normal)
        addCashButton.title = String.fontAwesomeIcon(name: .money)
        addCashButton.tintColor = .white
    }
    
    func getUser() -> Void {
        //If viewing another person's profile, user their userId. Otherwise, use yours.
        if let _ = userId {}
        else{userId = SessionManager.getUserId()}
        
        //SwiftSpinner.show("Loading...")
        MyFirebaseRef.getUserByID(id: userId!)
            .then{ (user) -> Void in
                self.user = user
                self.getBets()
            }.always{
                //SwiftSpinner.hide()
            }
    }
    
    func getBets() -> Void {
        //SwiftSpinner.show("Getting bets...")
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
                //SwiftSpinner.hide()
        }
    }
    
    func addCash() -> Void {
        //SwiftSpinner.show("Adding Cash...")
        MyFirebaseRef.addCashToUser(userId: SessionManager.getUserId(), cashToAdd: 10.00)
            .then{ () -> Void in
                ModalService.showSuccess(title: "Success", message: "Added $10 to your account, (refresh page).")
            }.catch{ (error) in
                ModalService.showError(title: "Sorry", message: "Could not add money to your account.")
            }.always{
                //SwiftSpinner.hide()
            }
    }
    
    func openEditProfile() -> Void {
        ModalService.showInfo(title: "Edit Profile", message: "Coming Soon...")
    }
    
    func openMessages() -> Void {
        let messagesViewController = storyBoard.instantiateViewController(withIdentifier: "MessagesViewController") as! MessagesViewController
        navigationController?.pushViewController(messagesViewController, animated: true)
    }
    
    func updateProfilePicture() -> Void {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }else{
            ModalService.showError(title: "Sorry", message: "Image Picker Not Available")
        }
    }
    
    func setUI() -> Void {
        setUserName()
        setProfileImage()
        setCash()
        setCurrentBets()
        setBetsWon()
    }
    
    func setNavBarButtons() -> Void {
        /* Apply buttons to navbar. */
        navigationController?.visibleViewController?.navigationItem.setRightBarButtonItems([messagesButton, editProfileButton, addCashButton], animated: true)
    }

    func setUserName() -> Void {
        if let _ = user!.userName {
            userNameLabel.text = user!.userName
        }else{
            userNameLabel.text = "User Name Not Set"
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
    
    func setCash() -> Void {
        if let _ = user!.cash {
            cashLabel.text = String(format: "$%.02f", user!.cash)
        }else{
            cashLabel.text = String(format: "$%.02f", 0)
        }
    }
    
    func setCurrentBets() -> Void {
        currentBetsLabel.text = String(describing: myBets.count)
    }
    
    func setBetsWon() -> Void {
        betsWonLabel.text = "0"
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
            cell.userName.text = self.user!.userName
            cell.userImage.kf.setImage(with: URL(string: self.user!.imageDownloadUrl))
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
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) -> Void {
        dismiss(animated: true, completion: nil)
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
