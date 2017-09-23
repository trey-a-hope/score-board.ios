import UIKit

class MessagesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    //Navbar buttons
    var addMessageButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(ConnectionManager.isConnectedToInternet()){
            initUI()
        }else{
            ModalService.showError(title: "Error", message: "No internet connection.")
        }
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
    
    func addMessage() -> Void {
        ModalService.showWarning(title: "Add Message", message: "Coming Soon")
    }
}

