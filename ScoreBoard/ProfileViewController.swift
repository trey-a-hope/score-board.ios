import Firebase
import FirebaseFirestore
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
    private var messagesButton: UIBarButtonItem!
    private var editProfileButton: UIBarButtonItem!
    private var adminButton: UIBarButtonItem!

    public var userId: String?
    private let imagePicker = UIImagePickerController()
    private let BetCellWidth: CGFloat = CGFloat(175)
    private let CellIdentifier: String = "Cell"
    private var user: User?
    private var myBets: [Bet] = [Bet]()
    private var myGames: [Game] = [Game]()
        
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ProfileViewController.loadData), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.visibleViewController?.title = "Profile"
        navigationController?.isNavigationBarHidden = false
        navigationController?.hidesBarsOnSwipe = false
        
        //If viewing another person's profile, user their userId
        if userId != nil {
            navigationController?.visibleViewController?.navigationItem.setRightBarButtonItems([messagesButton], animated: true)
        }
        //Otherwise, use yours
        else{
            navigationController?.visibleViewController?.navigationItem.setRightBarButtonItems([messagesButton, editProfileButton, adminButton], animated: true)
        }
    }

    func initUI() -> Void {
        //Configure imagepicker.
        imagePicker.delegate = self
        
        //Add refresh control.
        scrollView.refreshControl = refreshControl
        
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
    
    @objc func loadData() -> Void {
        let temp: String = userId == nil ? SessionManager.getUserId() : userId!
        
        when(fulfilled: MyFSRef.getUserById(id: temp), MyFSRef.getGamesForUser(userId: temp), MyFSRef.getBetsForUser(userId: temp))
            .then{ result -> Void in
                
                //Set user
                self.user = result.0
                //Set games
                self.myGames = result.1
                //Set bets
                self.myBets = result.2
                
                self.myBetsCollectionView.reloadData()
                self.myGamesCollectionView.reloadData()
                self.refreshControl.endRefreshing()
                
                self.setUI()
            }.catch{ (error) in
                print(error.localizedDescription)
            }.always{}
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
        if userId == SessionManager.getUserId() {
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
        if userId == SessionManager.getUserId() {
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
    
    @objc func openAdmin() -> Void {
        let adminTableViewController = storyBoard.instantiateViewController(withIdentifier: "AdminTableViewController") as! AdminTableViewController
        navigationController?.pushViewController(adminTableViewController, animated: true)
    }
    
    @objc func openEditProfile() -> Void {
        let editProfileViewController = storyBoard.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
        navigationController?.pushViewController(editProfileViewController, animated: true)
    }
    
    @objc func openMessages() -> Void {
        //UserId is coming in null for some reason???
        print(userId)
        print(SessionManager.getUserId())
        
        //If current user, navigate to list of message.
        if userId == SessionManager.getUserId() {
            let messagesViewController = storyBoard.instantiateViewController(withIdentifier: "MessagesViewController") as! MessagesViewController
            navigationController?.pushViewController(messagesViewController, animated: true)
        }
        //Otherwise, open message view directly to message this user.
        else{
            ModalService.showAlert(title: "Message " + (self.user?.userName)!, message: "Coming soon...", vc: self)
        }
    }
    
    @objc func updateProfilePicture() -> Void {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }else{
            ModalService.showAlert(title: "Sorry", message: "Image Picker Not Available", vc: self)
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
        if collectionView == myBetsCollectionView {
            return myBets.count
        }
        else if collectionView == myGamesCollectionView {
            return myGames.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) -> Void {
        
        var gameId: String!
        
        if collectionView == myBetsCollectionView {
            gameId = myBets[indexPath.row].gameId!
            
        }
        else if collectionView == myGamesCollectionView {
            gameId = myGames[indexPath.row].id!
        }
        
        let fullGameViewController = storyBoard.instantiateViewController(withIdentifier: "FullGameViewController") as! FullGameViewController
        fullGameViewController.gameId = gameId
        self.navigationController?.pushViewController(fullGameViewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == myBetsCollectionView {
            if let betCell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath) as? BetCell{
                
                let bet: Bet = myBets[indexPath.row]
                
                let homeTeam: NBATeam = NBATeamService.instance.teams.filter({ $0.id == bet.homeTeamId }).first!
                let awayTeam: NBATeam = NBATeamService.instance.teams.filter({ $0.id == bet.awayTeamId }).first!
                
                betCell.userName.text = self.user!.userName
                betCell.userImage.kf.setImage(with: URL(string: self.user!.imageDownloadUrl))
                betCell.userImage.round(borderWidth: 1, borderColor: UIColor.black)
                betCell.homeTeamImage.kf.setImage(with: URL(string: homeTeam.imageDownloadUrl))
                betCell.homeTeamImage.round(borderWidth: 1, borderColor: UIColor.black)
                betCell.homeTeamDigit.text = String(describing: bet.homeDigit!)
                betCell.awayTeamImage.kf.setImage(with: URL(string: awayTeam.imageDownloadUrl))
                betCell.awayTeamImage.round(borderWidth: 1, borderColor: UIColor.black)
                betCell.awayTeamDigit.text = String(describing: bet.awayDigit!)
                betCell.posted.text = ConversionService.timeAgoSinceDate(date: bet.timestamp)
                
                return betCell
            }
            fatalError("Unable to Dequeue Reusable Cell View")
        }
        else if collectionView == myGamesCollectionView {
            if let gameCell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath) as? GameCell{
                
                let game: Game = myGames[indexPath.row]

                let homeTeam: NBATeam = NBATeamService.instance.teams.filter({ $0.id == game.homeTeamId }).first!
                let awayTeam: NBATeam = NBATeamService.instance.teams.filter({ $0.id == game.awayTeamId }).first!
                
                gameCell.userName.text = self.user!.userName
                gameCell.homeTeamImage.kf.setImage(with: URL(string: homeTeam.imageDownloadUrl))
                gameCell.homeTeamImage.round(borderWidth: 1, borderColor: UIColor.black)
                gameCell.homeTeamScore.text = String(describing: game.homeTeamScore!)
                gameCell.awayTeamImage.kf.setImage(with: URL(string: awayTeam.imageDownloadUrl))
                gameCell.awayTeamImage.round(borderWidth: 1, borderColor: UIColor.black)
                gameCell.awayTeamScore.text = String(describing: game.awayTeamScore!)
                gameCell.potAmount.text = String(format: "$%.02f", game.potAmount)
                
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

