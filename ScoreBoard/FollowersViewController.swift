import UIKit


class FollowersViewController: UIViewController {
    @IBOutlet private weak var tableView    : UITableView!
    
    private var me                          : User!
    private var followers                   : [User]    = [User]() //People that follow me.
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
                self.getFollowers()
            }.always{}
    }
    
    private func getFollowers() -> Void {
        //Go from currentUser.followers array index 'startIndex' to 'startIndex + fetchSize'
        for userId in me.followers {
            MyFSRef.getUserById(id: userId)
                .then{ follower -> Void in
                    
                    self.followers.append(follower)
                    
                    if self.followers.count == self.me.followers.count {
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

extension FollowersViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followers.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user: User = followers[indexPath.row]
        
        ModalService.showAlert(title: user.userName, message: "Coming Soon...", vc: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FollowerCell", for: indexPath as IndexPath) as? FollowerCell{
            let user: User = followers[indexPath.row]
            
            cell.userName.text = user.userName
            cell.userImage.round(borderWidth: 0, borderColor: UIColor.black)
            cell.userImage.kf.setImage(with: URL(string: user.imageDownloadUrl))
            cell.unfollowBtn.addTarget(self, action: #selector(unfollow), for: .touchUpInside)
            cell.followBtn.addTarget(self, action: #selector(follow), for: .touchUpInside)
            
            if me.followings.contains(user.id) {
                cell.unfollowBtn.isHidden = false
            } else {
                cell.followBtn.isHidden = false
            }

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
}

