import Toaster
import UIKit

class FollowingsViewController: UIViewController {
    @IBOutlet private weak var tableView    : UITableView!
    
    private var me                          : User!
    private var followings                  : [User]    = [User]() //People I follow.
    private var startIndex                  : Int       = 0
    private var fetchSize                   : Int       = 10
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        initUI()
        getCurrentUser()
    }
    
    private func getCurrentUser() -> Void {
        MyFSRef.getUserById(id: SessionManager.getUserId())
            .then{ me -> Void in
                self.me = me
                self.getFollowings()
            }.always{}
    }
    
    private func getFollowings() -> Void {
        //Go from currentUser.followers array index 'startIndex' to 'startIndex + fetchSize'
        for userId in me.followings {
            MyFSRef.getUserById(id: userId)
                .then{ following -> Void in
                    
                    self.followings.append(following)
                    
                    if self.followings.count == self.me.followings.count {
                        self.tableView.reloadData()
                    }
                }.always{}
        }
    }
    
    private func initUI() -> Void {
        //Register cell and set delegate and data source for table view.
        tableView.register(UINib.init(nibName: "FollowerCell", bundle: nil), forCellReuseIdentifier: "FollowerCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func fetchMoreUsers() -> Void {
        startIndex += fetchSize
        //Fetch users
    }
    
    @objc private func unfollow() -> Void {
        ModalService.showAlert(title: "Unfollow", message: "", vc: self)
    }
    
    @objc private func follow() -> Void {
        ModalService.showAlert(title: "Follow", message: "", vc: self)
    }
    
}

extension FollowingsViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followings.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user: User = followings[indexPath.row]
        
        let otherProfileViewController = storyBoard.instantiateViewController(withIdentifier: "OtherProfileViewController") as! OtherProfileViewController
        otherProfileViewController.userId = user.id
        navigationController!.pushViewController(otherProfileViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FollowerCell", for: indexPath as IndexPath) as? FollowerCell{
            let user: User = followings[indexPath.row]
            
            cell.userName.text = user.userName
            cell.userImage.round(borderWidth: 0, borderColor: UIColor.black)
            cell.userImage.kf.setImage(with: URL(string: user.imageDownloadUrl))
            
            return cell
        }
        fatalError("Unable to Dequeue Reusable Supplementary View")
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //If on the last row of users, call method to fetch more.
        if (indexPath.row == tableView.numberOfRows(inSection: 0))
        {
            //fetchMoreUsers()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return Constants.FOLLOWER_CELL_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let user: User = followings[editActionsForRowAt.row]
        
        //Message button.
        let message = UITableViewRowAction(style: .normal, title: "Message") { action, index in
            ModalService.showAlert(title: "Message " + user.userName, message: "Coming Soon...", vc: self)
        }
        message.backgroundColor = GMColor.deepPurple500Color()
        
        //Follower button.
        let follow: UITableViewRowAction!
        
        //Unfollow user.
        if me.followings.contains(user.id) {
            follow = UITableViewRowAction(style: .normal, title: "Unfollow") { action, index in
                self.me.followings  = self.me.followings.filter { $0 != user.id }
                user.followers      = user.followers.filter { $0 != self.me.id }
                
                MyFSRef.followUser(myUserId: self.me.id, myFollowings: self.me.followings, theirUserId: user.id, theirFollowers: user.followers)
                    .then{ () -> Void in
                        Toast(text: "You unfollowed " + user.userName).show()
                        self.tableView.reloadRows(at: [ editActionsForRowAt ], with: .none)
                    }.always{}
            }
            follow.backgroundColor = GMColor.red500Color()
        }
            //Follow user.
        else{
            follow = UITableViewRowAction(style: .normal, title: "Follow") { action, index in
                self.me.followings.append(user.id)
                user.followers.append(self.me.id)
                
                MyFSRef.followUser(myUserId: self.me.id, myFollowings: self.me.followings, theirUserId: user.id, theirFollowers: user.followers)
                    .then{ () -> Void in
                        Toast(text: "You followed " + user.userName).show()
                        self.tableView.reloadRows(at: [ editActionsForRowAt ], with: .none)
                    }.always{}
            }
            follow.backgroundColor = GMColor.blue500Color()
        }
        
        return [ follow, message ]
    }
}

