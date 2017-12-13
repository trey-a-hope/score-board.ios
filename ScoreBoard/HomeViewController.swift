import PromiseKit
import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mostPointsLabel: UILabel!
    @IBOutlet weak var pointsCollectionView: UICollectionView!
    @IBOutlet weak var mostBetsWonLabel: UILabel!
    @IBOutlet weak var betsWonCollectionView: UICollectionView!
    @IBOutlet weak var mostGamessWonLabel: UILabel!
    @IBOutlet weak var gamesWonCollectionView: UICollectionView!
        
    var mostPointsUsers: [User] = [User]()
    var mostBetsWonUsers: [User] = [User]()
    var mostGamesWonUsers: [User] = [User]()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(HomeViewController.loadData), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set bet collection view delegate and datasource.
        pointsCollectionView.delegate = self
        pointsCollectionView.dataSource = self
        betsWonCollectionView.delegate = self
        betsWonCollectionView.dataSource = self
        gamesWonCollectionView.delegate = self
        gamesWonCollectionView.dataSource = self
        
        pointsCollectionView.register(UINib.init(nibName: "UserCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        betsWonCollectionView.register(UINib.init(nibName: "UserCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        gamesWonCollectionView.register(UINib.init(nibName: "UserCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        
        scrollView.refreshControl = refreshControl
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.visibleViewController?.navigationItem.titleView = nil
        navigationController?.visibleViewController?.navigationItem.title = "Home"
        navigationController?.visibleViewController?.navigationItem.setRightBarButtonItems([], animated: true)
        navigationController?.isNavigationBarHidden = false
        navigationController?.hidesBarsOnSwipe = false
    }
    
    @objc func loadData() -> Void {
        //Fetch users and games
        when(fulfilled: MyFSRef.getTopUsers(category: "points", numberOfUsers: 5), MyFSRef.getTopUsers(category: "betsWon", numberOfUsers: 5), MyFSRef.getTopUsers(category: "gamesWon", numberOfUsers: 5))
            .then{ (result) -> Void in
                //Get the top 5 users with the most points
                self.mostPointsUsers = result.0
                self.mostPointsLabel.text = "Most Points - " + String(describing: self.mostPointsUsers[0].points!)
                self.pointsCollectionView.reloadData()
                //Get the top 5 users with the most bets won
                self.mostBetsWonUsers = result.1
                self.mostBetsWonLabel.text = "Most Bets Won - " + String(describing: self.mostBetsWonUsers[0].betsWon!)
                self.betsWonCollectionView.reloadData()
                //Get the top 5 users with the most games won
                self.mostGamesWonUsers = result.2
                self.mostGamessWonLabel.text = "Most Games Won - " + String(describing: self.mostGamesWonUsers[0].gamesWon!)
                self.gamesWonCollectionView.reloadData()
                
            }.always{
                self.refreshControl.endRefreshing()
            }
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    //Child section dimensions.
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //NOTE: Height here should always equal height in XIB file.
        switch collectionView {
            case pointsCollectionView:
                return CGSize(width: CGFloat(250), height: pointsCollectionView.bounds.height)
            case betsWonCollectionView:
                return CGSize(width: CGFloat(250), height: betsWonCollectionView.bounds.height)
            case gamesWonCollectionView:
                return CGSize(width: CGFloat(250), height: gamesWonCollectionView.bounds.height)
            default:
                return CGSize(width: CGFloat(250), height: pointsCollectionView.bounds.height)
        }
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

extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
            case pointsCollectionView:
                return mostPointsUsers.count
            case betsWonCollectionView:
                return mostBetsWonUsers.count
            case gamesWonCollectionView:
                return mostGamesWonUsers.count
            default:
                return mostPointsUsers.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) -> Void {
        var user: User!
        
        switch collectionView {
            case pointsCollectionView:
                user = mostPointsUsers[indexPath.row]
            case betsWonCollectionView:
                user = mostBetsWonUsers[indexPath.row]
            case gamesWonCollectionView:
                user = mostGamesWonUsers[indexPath.row]
            default:break
        }
        
        if user.id == SessionManager.getUserId() {
            ModalService.showAlert(title: "TODO", message: "Navigate to profile view.", vc: self)
        }else{
            let otherProfileViewController = storyBoard.instantiateViewController(withIdentifier: "OtherProfileViewController") as! OtherProfileViewController
            otherProfileViewController.userId = user.id
            navigationController!.pushViewController(otherProfileViewController, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? UserCell{
            let user: User!
            
            switch collectionView {
                case pointsCollectionView:
                    user = mostPointsUsers[indexPath.row]
                case betsWonCollectionView:
                    user = mostBetsWonUsers[indexPath.row]
                case gamesWonCollectionView:
                    user = mostGamesWonUsers[indexPath.row]
                default:
                    user = mostPointsUsers[indexPath.row]
            }
            
            switch(indexPath.row) {
                //1st Place
                case 0:
                    cell.card.backgroundColor = GMColor.purple700Color()
                    break
                //2nd Place
                case 1:
                    cell.card.backgroundColor = GMColor.grey700Color()
                    break
                //3rd Place
                case 2:
                    cell.card.backgroundColor = Constants.primaryColor
                    break
                default:break
            }
            
            cell.userName.text = user.userName
            cell.points.text = user.points! == 1 ? "1 pt" : String(describing: user.points!) + " pts"
            cell.betsWon.text = user.betsWon! == 1 ? "1 bet won" : String(describing: user.betsWon!) + " bets won"
            cell.gamesWon.text = user.gamesWon! == 1 ? "1 game won" : String(describing: user.gamesWon!) + " games won"
            cell.image.kf.setImage(with: URL(string: user.imageDownloadUrl))
            cell.image.round(borderWidth: 4, borderColor: .white)
            
            return cell
        }
        fatalError("Unable to Dequeue Reusable Cell View")
    }
}

