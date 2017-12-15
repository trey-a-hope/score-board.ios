import Firebase
import FirebaseFirestore
import FontAwesome_swift
import Foundation
import Material
import PromiseKit
import Kingfisher
import UIKit

class MyProfileViewController : UIViewController {
    @IBOutlet private weak var scrollView               : UIScrollView!
    @IBOutlet private weak var profileImage             : UIImageView!
    @IBOutlet private weak var userNameLabel            : UILabel!
    @IBOutlet private weak var pointsLabel              : UILabel!
    @IBOutlet private weak var gamesWonLabel            : UILabel!
    @IBOutlet private weak var betsWonLabel             : UILabel!
    @IBOutlet private weak var locationLabel            : UILabel!
    @IBOutlet private weak var myBetsLabel              : UILabel!
    @IBOutlet private weak var myGamesLabel             : UILabel!
    @IBOutlet private weak var myBetsCollectionView     : UICollectionView!
    @IBOutlet private weak var myGamesCollectionView    : UICollectionView!
    @IBOutlet private weak var followersLabel           : UILabel!
    @IBOutlet private weak var followingsLabel          : UILabel!
    
    //Navbar buttons
    private var messagesButton                          : UIBarButtonItem!
    private var editProfileButton                       : UIBarButtonItem!
    private var adminButton                             : UIBarButtonItem!

    private let imagePicker                             : UIImagePickerController   = UIImagePickerController()
    private let BetCellWidth                            : CGFloat                   = CGFloat(175)
    private let CellIdentifier                          : String                    = "Cell"
    private var me                                      : User!
    private var myBets                                  : [Bet]                     = [Bet]()
    private var myGames                                 : [Game]                    = [Game]()
        
    private lazy var refreshControl                     : UIRefreshControl          = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MyProfileViewController.loadData), for: UIControlEvents.valueChanged)
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
        

        navigationController?.visibleViewController?.navigationItem.setRightBarButtonItems([messagesButton, editProfileButton, adminButton], animated: true)
    }

    private func initUI() -> Void {
        //Configure imagepicker.
        imagePicker.delegate                = self
        
        //Add refresh control.
        scrollView.refreshControl           = refreshControl
        
        //Configure my bets collection view
        myBetsCollectionView.dataSource     = self
        myBetsCollectionView.delegate       = self
        myGamesCollectionView.dataSource    = self
        myGamesCollectionView.delegate      = self
        myBetsCollectionView.register(UINib.init(nibName: "BetCell", bundle: nil), forCellWithReuseIdentifier: CellIdentifier)
        myGamesCollectionView.register(UINib.init(nibName: "GameCell", bundle: nil), forCellWithReuseIdentifier: CellIdentifier)
        
        //Configure profile imageview.
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(updateProfilePicture)))
        profileImage.isUserInteractionEnabled = true
        
        //Messages Button
        messagesButton = UIBarButtonItem(
            title: "Add",
            style: .plain,
            target: self,
            action: #selector(MyProfileViewController.goToMessages)
        )
        messagesButton.setTitleTextAttributes(Constants.FONT_AWESOME_ATTRIBUTES, for: .normal)
        messagesButton.title = String.fontAwesomeIcon(name: .envelope)
        messagesButton.tintColor = .white
        
        //Edit Profile Button
        editProfileButton = UIBarButtonItem(
            title: "Add",
            style: .plain,
            target: self,
            action: #selector(MyProfileViewController.goToEditProfile)
        )
        editProfileButton.setTitleTextAttributes(Constants.FONT_AWESOME_ATTRIBUTES, for: .normal)
        editProfileButton.title = String.fontAwesomeIcon(name: .pencil)
        editProfileButton.tintColor = .white
        
        //Admin Button
        adminButton = UIBarButtonItem(
            title: "Add",
            style: .plain,
            target: self,
            action: #selector(MyProfileViewController.goToAdmin)
        )
        adminButton.setTitleTextAttributes(Constants.FONT_AWESOME_ATTRIBUTES, for: .normal)
        adminButton.title = String.fontAwesomeIcon(name: .cogs)
        adminButton.tintColor = .white
        
        followersLabel.isUserInteractionEnabled = true
        followersLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MyProfileViewController.goToFollowers)))
        
        followingsLabel.isUserInteractionEnabled = true
        followingsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MyProfileViewController.goToFollowings)))
    }
    

    
    @objc private func loadData() -> Void {
        when(fulfilled: MyFSRef.getUserById(id: SessionManager.getUserId()), MyFSRef.getGamesForUser(userId: SessionManager.getUserId()), MyFSRef.getBetsForUser(userId: SessionManager.getUserId()))
            .then{ result -> Void in
                
                //Set user
                self.me         = result.0
                //Set games
                self.myGames    = result.1
                //Set bets
                self.myBets     = result.2
                
                self.myBetsCollectionView.reloadData()
                self.myGamesCollectionView.reloadData()
                self.refreshControl.endRefreshing()
                
                self.setUI()
            }.catch{ (error) in
                print(error.localizedDescription)
            }.always{}
    }
    
    private func setUI() -> Void {
        //Profile image
        profileImage.round(borderWidth: 8.0, borderColor: UIColor.white)
        profileImage.kf.setImage(with: URL(string: me.imageDownloadUrl))
        
        //Location
        if let _ = me.city, let _ = me.stateId {
            locationLabel.text = me.city + ", " + StateService.getStateAbbreviation(me.stateId)
        }else{
            locationLabel.text = "No location"
        }
        
        //Username
        userNameLabel.text = me.userName
        
        //Points
        pointsLabel.text = String(describing: me.points!)
        
        //Followers/Followings TODO: Add on touch method to navigate to list of users.
        followersLabel.text     = String(describing: me.followers.count)
        followingsLabel.text    = String(describing: me.followings.count)
        
        //Games won
        gamesWonLabel.text = "Games Won - " + String(describing: me.gamesWon!)
        
        //Bets won
        betsWonLabel.text = "Bets Won - " + String(describing: me.betsWon!)
        
        //My bets label
        myBetsLabel.text = "My Bets - " + String(describing: myBets.count)
        
        //My games label
        myGamesLabel.text = "My Games - " + String(describing: myGames.count)
    }
    
    @objc private func goToAdmin() -> Void {
        let adminTableViewController = storyBoard.instantiateViewController(withIdentifier: "AdminTableViewController") as! AdminTableViewController
        navigationController?.pushViewController(adminTableViewController, animated: true)
    }
    
    @objc private func goToEditProfile() -> Void {
        let editProfileViewController = storyBoard.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
        navigationController?.pushViewController(editProfileViewController, animated: true)
    }
    
    @objc private func goToMessages() -> Void {
        let messagesViewController = storyBoard.instantiateViewController(withIdentifier: "MessagesViewController") as! MessagesViewController
        navigationController?.pushViewController(messagesViewController, animated: true)
    }
    
    @objc private func goToFollowers() -> Void {
        let followersViewController = storyBoard.instantiateViewController(withIdentifier: "FollowersViewController") as! FollowersViewController
        navigationController?.pushViewController(followersViewController, animated: true)
    }
    
    @objc private func goToFollowings() -> Void {
        let followingsViewController = storyBoard.instantiateViewController(withIdentifier: "FollowingsViewController") as! FollowingsViewController
        navigationController?.pushViewController(followingsViewController, animated: true)
    }
    
    @objc private func updateProfilePicture() -> Void {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.sourceType      = .photoLibrary;
            imagePicker.allowsEditing   = false
            present(imagePicker, animated: true, completion: nil)
        }else{
            ModalService.showAlert(title: "Sorry", message: "Image Picker Not Available", vc: self)
        }
    }
}

extension MyProfileViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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

extension MyProfileViewController: UICollectionViewDataSource {
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
                
                betCell.userName.text = me.userName
                betCell.userImage.kf.setImage(with: URL(string: me.imageDownloadUrl))
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
                
                gameCell.userName.text = me.userName
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

extension MyProfileViewController : UIImagePickerControllerDelegate {
    
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

