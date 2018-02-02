import UIKit

class NotificationsTableViewController : UITableViewController {
    
    @IBOutlet private weak var newMessageSwitch: UISwitch!
    
    private var currentUser: User!
    
    override func viewDidLoad() {
        self.tableView.allowsSelection = false
        getCurrentUser()
    }
    
    private func getCurrentUser() -> Void {
        MyFSRef.getUserById(id: SessionManager.getUserId())
            .then{ user -> Void in
                self.currentUser = user
                self.initUI()
            }.always{}
    }
    
    func initUI() -> Void {
        //New Message Notifications
        self.newMessageSwitch.setOn(currentUser.notifications["newMessage"]!, animated: false)
        self.newMessageSwitch.addTarget(self, action: #selector(self.toggleNewMessageSwitch), for: UIControlEvents.valueChanged)
    }
    
    @objc func toggleNewMessageSwitch(uiSwitch: UISwitch) {
        let isOn = uiSwitch.isOn
        //This is not a topic, so no need to subscribe/unsubscribe.
        currentUser.notifications["newMessage"] = isOn
        MyFSRef.updateNotifications(id: currentUser.id, notifications: currentUser.notifications)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) -> Void {
        view.tintColor = .gray
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.black
    }
}


