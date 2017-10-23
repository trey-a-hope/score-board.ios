import UIKit

class MessagesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    //Navbar buttons
    var addMessageButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func initUI() -> Void {
        //Add Message Button
        addMessageButton = UIBarButtonItem(
            title: "Add",
            style: .plain,
            target: self,
            action: #selector(MessagesViewController.addMessage)
        )
        addMessageButton.setTitleTextAttributes(Constants.FONT_AWESOME_ATTRIBUTES, for: .normal)
        addMessageButton.title = String.fontAwesomeIcon(name: .plus)
        addMessageButton.tintColor = .white
        
        navigationItem.setRightBarButtonItems([addMessageButton], animated: true)
    }
    
    @objc func addMessage() -> Void {
        let searchUserViewController = storyBoard.instantiateViewController(withIdentifier: "SearchUserViewController") as! SearchUserViewController
        navigationController?.pushViewController(searchUserViewController, animated: true)    }
}

