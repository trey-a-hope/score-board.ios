import Material
import Stripe
import UIKit

class Charge {
    var amount      : Double!
    var description : String!
    var timestamp   : Date!
}

class PaymentHistoryTableViewController : UITableViewController {
    private var user    : User!
    private var charges : [Charge] = [Charge]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Register xib for table view cell.
        tableView.register(UINib.init(nibName: "PaymentChargeCell", bundle: nil), forCellReuseIdentifier: "PaymentChargeCell")
        
        getUser()
    }
    
    private func getUser() -> Void {
        MyFSRef.getUserById(id: SessionManager.getUserId())
            .then{ user -> Void in
                self.user = user
                self.loadTransactions()
            }.always{}
    }
    
    private func loadTransactions() -> Void {
        StripeAPIClient.listAllCharges(customerId: user.customerId)
            .then{ response -> Void in
                if let error = response.error {
                    print(error)
                    ModalService.showAlert(title: "Error", message: error.localizedDescription, vc: self)
                }else{
                    if let JSON = response.result.value {
                        do{
                            let json            : NSDictionary  = try JSONSerializer.toDictionary(JSON)
                            let transactions    : NSArray       = json["data"] as! NSArray
                            
                            if transactions.count == 0 {
                                ModalService.showAlert(title: "No transactions.", message: "When you register for camps, they will display here.", vc: self)
                            }else{
                                for transaction in transactions {
                                    let transactionData : NSDictionary  = transaction as! NSDictionary
                                    let charge          : Charge        = Charge()
                                    
                                    charge.amount                       = (transactionData["amount"] as! Double / 100)
                                    charge.description                  = transactionData["description"] as! String
                                    charge.timestamp                    = NSDate(timeIntervalSince1970: TimeInterval(transactionData["created"] as! Int)) as Date
                                    
                                    self.charges.append(charge)
                                }
                                
                                self.tableView.reloadData()
                            }
                        }catch let error as NSError{
                            ModalService.showAlert(title: "Error", message: error.localizedDescription, vc: self)
                        }
                    }
                }
                
            }.always{}
    }
}

//Table View Functions
extension PaymentHistoryTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let charge: Charge = charges[indexPath.row]
        
        let paymentHistoryDetailsViewController = storyBoard.instantiateViewController(withIdentifier: "PaymentHistoryDetailsViewController") as! PaymentHistoryDetailsViewController
        paymentHistoryDetailsViewController.charge = charge
        navigationController!.pushViewController(paymentHistoryDetailsViewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return charges.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentChargeCell", for: indexPath as IndexPath) as? PaymentChargeCell{
            let charge: Charge = charges[indexPath.row]
            
            cell._description.text = charge.description!
            cell.amount.text = String(format: "$%.02f", charge.amount!)
            return cell
        }
        fatalError("Unable to Dequeue Reusable Supplementary View")
    }
    
    //    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
    //        let conversation: Conversation = conversations[editActionsForRowAt.row]
    //
    //        //Mute conversation button.
    //        let mute = UITableViewRowAction(style: .normal, title: "Mute") { action, index in
    //
    //        }
    //        mute.backgroundColor = .gray
    //
    //        //Delete conversation button.
    //        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
    //
    //        }
    //        delete.backgroundColor = .red
    //
    //        return [delete, mute]
    //    }
    
}


