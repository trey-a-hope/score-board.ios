import SwiftSpinner
import UIKit

class GamesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var games: [Game] = [Game]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(ConnectionManager.isConnectedToInternet()){
            initUI()
            getGames()
        }else{
            ModalService.displayNoInternetAlert(vc: self)
        }


    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reInitUI()
    }
    
    func initUI() -> Void {
        //Register cell for table.
        let XIBCell = UINib.init(nibName: "GameTableViewCell", bundle: nil)
        tableView.register(XIBCell, forCellReuseIdentifier: "GameTableViewCell")
        
        //Set delegate and data source.
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func reInitUI() -> Void {
        //Set title of view.
        self.navigationController?.visibleViewController?.title = "Games"
    }
    
    func getGames() -> Void {
        MyFirebaseRef.getGames()
            .then{ (games) -> Void in
            self.games = games
            self.tableView.reloadData()
        }.catch{ (error) in
    
        }
        .always {
        }
    }
}

extension GamesViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let game: Game = games[indexPath.row]
        print(game.id)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "GameTableViewCell", for: indexPath as IndexPath) as? GameTableViewCell{
            let game: Game = games[indexPath.row]

            cell.test.text = "Hawks vs. Celtics"
            return cell
        }
        fatalError("Unable to Dequeue Reusable Supplementary View")
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let game: Game = games[editActionsForRowAt.row]
        
        //Mute conversation button.
        let mute = UITableViewRowAction(style: .normal, title: "Mute") { action, index in
//            let popup = PopupDialog(title: "Mute Thread with " + conversation.recipientname, message: "Are you sure?")
//            popup.addButtons([
//                DefaultButton(title: "YES") {
//                    ModalService.displayToast("Mute Thread", UIColor.gray)
//                }, CancelButton(title: "CANCEL") {
//                }
//                ])
//            self.present(popup, animated: true, completion: nil)
        }
        mute.backgroundColor = .gray
        
        //Delete conversation button.
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
//            let popup = PopupDialog(title: "Delete Thread with " + conversation.recipientname, message: "Are you sure?")
//            popup.addButtons([
//                DefaultButton(title: "YES") {
//                    ModalService.displayToast("Delete Thread", UIColor.gray)
//                }, CancelButton(title: "CANCEL") {
//                }
//                ])
//            self.present(popup, animated: true, completion: nil)
        }
        delete.backgroundColor = .red
        
        return [delete, mute]
    }

}




