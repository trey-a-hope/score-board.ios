import Firebase
import FirebaseFirestore
import FontAwesome_swift
import Foundation
import Material
import PromiseKit
import Kingfisher
import UIKit

class OtherProfileViewController: UIViewController {
    @IBOutlet private weak var scrollView               : UIScrollView!
    @IBOutlet private weak var profileImage             : UIImageView!
    @IBOutlet private weak var userNameLabel            : UILabel!
    @IBOutlet private weak var pointsLabel              : UILabel!
    @IBOutlet private weak var gamesWonLabel            : UILabel!
    @IBOutlet private weak var betsWonLabel             : UILabel!
    @IBOutlet private weak var locationLabel            : UILabel!
    @IBOutlet private weak var theirBetsLabel           : UILabel!
    @IBOutlet private weak var theirGamesLabel          : UILabel!
    @IBOutlet private weak var theirBetsCollectionView  : UICollectionView!
    @IBOutlet private weak var theirGamesCollectionView : UICollectionView!
    @IBOutlet private weak var followBtn                : UIButton!
    @IBOutlet private weak var followersLabel           : UILabel!
    @IBOutlet private weak var followingsLabel          : UILabel!
    
    //Navbar buttons
    private var messagesButton                          : UIBarButtonItem!
    private var editProfileButton                       : UIBarButtonItem!
    private var adminButton                             : UIBarButtonItem!
    
    public var userId                                   : String?
    private let imagePicker                             : UIImagePickerController   = UIImagePickerController()
    private let BetCellWidth                            : CGFloat                   = CGFloat(175)
    private let CellIdentifier                          : String                    = "Cell"
    private var me                                      : User!
    private var otherUser                               : User!
    private var theirBets                               : [Bet]                     = [Bet]()
    private var theirGames                              : [Game]                    = [Game]()
    
    private lazy var refreshControl                     : UIRefreshControl          = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(OtherProfileViewController.loadData), for: UIControlEvents.valueChanged)
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

        navigationController?.visibleViewController?.navigationItem.setRightBarButtonItems([messagesButton], animated: true)
        followBtn.isHidden = false
    }
    
    private func initUI() -> Void {
        //Configure imagepicker.
        imagePicker.delegate                = self
        
        //Add refresh control.
        scrollView.refreshControl           = refreshControl
        
        //Configure my bets collection view
        theirBetsCollectionView.dataSource     = self
        theirBetsCollectionView.delegate       = self
        theirGamesCollectionView.dataSource    = self
        theirGamesCollectionView.delegate      = self
        theirBetsCollectionView.register(UINib.init(nibName: "BetCell", bundle: nil), forCellWithReuseIdentifier: CellIdentifier)
        theirGamesCollectionView.register(UINib.init(nibName: "GameCell", bundle: nil), forCellWithReuseIdentifier: CellIdentifier)
        
        //Messages Button
        messagesButton = UIBarButtonItem(
            title: "Add",
            style: .plain,
            target: self,
            action: #selector(OtherProfileViewController.goToMessages)
        )
        messagesButton.setTitleTextAttributes(Constants.FONT_AWESOME_ATTRIBUTES, for: .normal)
        messagesButton.title = String.fontAwesomeIcon(name: .envelope)
        messagesButton.tintColor = .white
        
        followersLabel.isUserInteractionEnabled = true
        followersLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(OtherProfileViewController.goToFollowers)))
        
        followingsLabel.isUserInteractionEnabled = true
        followingsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(OtherProfileViewController.goToFollowings)))
    }
    
    @objc private func loadData() -> Void {
        when(fulfilled: MyFSRef.getUserById(id: SessionManager.getUserId()), MyFSRef.getUserById(id: userId!), MyFSRef.getGamesForUser(userId: userId!), MyFSRef.getBetsForUser(userId: userId!))
            .then{ result -> Void in
                
                //Set me
                self.me         = result.0
                //Set other user
                self.otherUser  = result.1
                //Set games
                self.theirGames = result.2
                //Set bets
                self.theirBets  = result.3
                
                self.theirBetsCollectionView.reloadData()
                self.theirGamesCollectionView.reloadData()
                self.refreshControl.endRefreshing()
                
                //If following user...
                if self.me.followings.contains(self.otherUser.id) {
                    self.followBtn.setTitle("Unfollow",for: .normal)
                }else{
                    self.followBtn.setTitle("Follow",for: .normal)
                }
                
                self.setUI()
            }.catch{ (error) in
                print(error.localizedDescription)
            }.always{}
    }
    
    private func setUI() -> Void {
        //Profile image
        profileImage.round(borderWidth: 8.0, borderColor: UIColor.white)
        profileImage.kf.setImage(with: URL(string: otherUser.imageDownloadUrl))
        
        //Location
        if let _ = otherUser.city, let _ = otherUser.stateId {
            locationLabel.text = otherUser.city + ", " + StateService.getStateAbbreviation(otherUser.stateId)
        }else{
            locationLabel.text = "No location"
        }
        
        //Username
        userNameLabel.text = otherUser.userName
        
        //Points
        pointsLabel.text = String(describing: otherUser.points!)
        
        //Followers/Followings TODO: Add on touch method to navigate to list of users.
        followersLabel.text     = String(describing: otherUser.followers.count)
        followingsLabel.text    = String(describing: otherUser.followings.count)
        
        //Games won
        gamesWonLabel.text = "Games Won - " + String(describing: otherUser.gamesWon!)
        
        //Bets won
        betsWonLabel.text = "Bets Won - " + String(describing: otherUser.betsWon!)
        
        //My bets label, gender specific
        if let _ = otherUser.gender {
            theirBetsLabel.text = otherUser.gender == "F" ? "Her bets - " : "His bets - "
        }else{
            theirBetsLabel.text = "Their bets - "
        }
        theirBetsLabel.text = theirBetsLabel.text! + String(describing: theirBets.count)
        
        //My games label, gender specific
        if let _ = otherUser.gender {
            theirGamesLabel.text = otherUser.gender == "F" ? "Her games - " : "His games - "
        }else{
            theirGamesLabel.text = "Their games - "
        }
        theirGamesLabel.text = theirGamesLabel.text! + String(describing: theirGames.count)
    }
    
    @objc private func goToMessages() -> Void {
        ModalService.showAlert(title: "Messages", message: "Coming Soon...", vc: self)
    }
    
    @objc private func goToFollowers() -> Void {
        let followersViewController = storyBoard.instantiateViewController(withIdentifier: "FollowersViewController") as! FollowersViewController
        navigationController?.pushViewController(followersViewController, animated: true)
    }
    
    @objc private func goToFollowings() -> Void {
        let followingsViewController = storyBoard.instantiateViewController(withIdentifier: "FollowingsViewController") as! FollowingsViewController
        navigationController?.pushViewController(followingsViewController, animated: true)
    }
    
    /// Follows/unfollows a user.
    /// - returns: Void
    /// - throws: No error.
    @IBAction private func updateUserFollowing() -> Void {
        //If following user, unfollow them.
        if me.followings.contains(otherUser.id) {
            me.followings       = me.followings.filter { $0 != otherUser.id }
            otherUser.followers = otherUser.followers.filter { $0 != me.id }
        }else{
            me.followings.append(otherUser.id)
            otherUser.followers.append(me.id)
        }
        
        MyFSRef.followUser(myUserId: me.id, myFollowings: me.followings, theirUserId: otherUser.id, theirFollowers: otherUser.followers)
            .then{ () -> Void in
                //If following user...
                if self.me.followings.contains(self.otherUser.id) {
                    self.followBtn.setTitle("Unfollow",for: .normal)
                }else{
                    self.followBtn.setTitle("Follow",for: .normal)
                }
            }.always{}
    }
}

extension OtherProfileViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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

extension OtherProfileViewController: UICollectionViewDataSource {
    //Collection View Data Source Methods.
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == theirBetsCollectionView {
            return theirBets.count
        }
        else if collectionView == theirGamesCollectionView {
            return theirGames.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) -> Void {
        
        var gameId: String!
        
        if collectionView == theirBetsCollectionView {
            gameId = theirBets[indexPath.row].gameId!
            
        }
        else if collectionView == theirGamesCollectionView {
            gameId = theirGames[indexPath.row].id!
        }
        
        let fullGameViewController = storyBoard.instantiateViewController(withIdentifier: "FullGameViewController") as! FullGameViewController
        fullGameViewController.gameId = gameId
        self.navigationController?.pushViewController(fullGameViewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == theirBetsCollectionView {
            if let betCell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath) as? BetCell{
                
                let bet: Bet = theirBets[indexPath.row]
                
                let ht = NBATeam.all.filter({ $0.name == bet.homeTeam }).first!
                let at = NBATeam.all.filter({ $0.name == bet.awayTeam }).first!
                
                betCell.userName.text = self.otherUser.userName
                betCell.userImage.kf.setImage(with: URL(string: self.otherUser.imageDownloadUrl))
                betCell.userImage.round(borderWidth: 1, borderColor: UIColor.black)
                betCell.homeTeamImage.kf.setImage(with: URL(string: ht.imageDownloadUrl))
                betCell.homeTeamImage.round(borderWidth: 1, borderColor: UIColor.black)
                betCell.homeTeamDigit.text = String(describing: bet.homeDigit!)
                betCell.awayTeamImage.kf.setImage(with: URL(string: at.imageDownloadUrl))
                betCell.awayTeamImage.round(borderWidth: 1, borderColor: UIColor.black)
                betCell.awayTeamDigit.text = String(describing: bet.awayDigit!)
                betCell.posted.text = ConversionService.timeAgoSinceDate(date: bet.timestamp)
                
                return betCell
            }
            fatalError("Unable to Dequeue Reusable Cell View")
        }
        else if collectionView == theirGamesCollectionView {
            if let gameCell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath) as? GameCell{
                
                let game: Game = theirGames[indexPath.row]
                
                let ht = NBATeam.all.filter({ $0.name == game.homeTeam }).first!
                let at = NBATeam.all.filter({ $0.name == game.awayTeam }).first!
                
                gameCell.userName.text = self.otherUser.userName
                gameCell.homeTeamImage.kf.setImage(with: URL(string: ht.imageDownloadUrl))
                gameCell.homeTeamImage.round(borderWidth: 1, borderColor: UIColor.black)
                gameCell.homeTeamScore.text = String(describing: game.homeTeamScore!)
                gameCell.awayTeamImage.kf.setImage(with: URL(string: at.imageDownloadUrl))
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

extension OtherProfileViewController : UIImagePickerControllerDelegate {
    
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


