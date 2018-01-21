import Material
import Stripe
import UIKit

class PaymentMethodViewController : UIViewController {
    @IBOutlet private weak var cardInfo : UILabel!
    @IBOutlet private weak var spinner  : UIActivityIndicatorView!
    
    private var addCardBtn              : UIBarButtonItem!
    private var updateCardBtn           : UIBarButtonItem!
    private var removeCardBtn           : UIBarButtonItem!
    
    private var user                    : User!
    private var cardId                  : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        getUser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getCustomerInformation()
    }
    
    private func initUI() -> Void {
        hideKeyboardWhenTappedAround()
        
        //Add Button
        addCardBtn = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addUpdateCard)
        )
        
        //Update Button
        updateCardBtn = UIBarButtonItem(
            barButtonSystemItem: .compose,
            target: self,
            action: #selector(addUpdateCard)
        )
        
        //Remove Button
        removeCardBtn = UIBarButtonItem(
            barButtonSystemItem: .trash,
            target: self,
            action: #selector(removeCard)
        )
    }
    
    private func getUser() -> Void {
        MyFSRef.getUserById(id: SessionManager.getUserId())
            .then{ user -> Void in
                self.user = user
                self.getCustomerInformation()
            }.always{}
    }
    
    private func getCustomerInformation() -> Void {
        spinner.isHidden = false
        spinner.startAnimating()
        
        StripeAPIClient.retrieveCustomer(customerId: user.customerId)
            .then{ response -> Void in
                if let error = response.error {
                    print(error)
                    ModalService.showAlert(title: "Error", message: error.localizedDescription, vc: self)
                    
                    self.spinner.isHidden = true
                    self.spinner.stopAnimating()
                }else{
                    if let JSON = response.result.value {
                        do{
                            let json    : NSDictionary  = try JSONSerializer.toDictionary(JSON)
                            let sources : NSDictionary  = json["sources"] as! NSDictionary
                            let cards   : NSArray       = sources["data"] as! NSArray
                            
                            //check to see if the user has any cards on recrod first before trying to subscript it.
                            if cards.count > 0 {
                                let defaultCard: NSDictionary = cards[0] as! NSDictionary
                                
                                print(defaultCard)
                                
                                self.cardId       = defaultCard["id"] as! String
                                let brand: String = defaultCard["brand"] as! String
                                let last4: String = defaultCard["last4"] as! String
                                
                                self.cardInfo.text = brand + " ending in " + last4
                                self.navigationItem.setRightBarButtonItems([self.removeCardBtn, self.updateCardBtn], animated: false)
                                
                                self.spinner.isHidden = true
                                self.spinner.stopAnimating()
                            }else{
                                self.navigationItem.setRightBarButtonItems([self.addCardBtn], animated: false)
                                
                                self.cardInfo.text = "Currently no card on record."
                                
                                self.spinner.isHidden = true
                                self.spinner.stopAnimating()
                            }
                        }catch let _ as NSError{
                            self.spinner.isHidden = true
                            self.spinner.stopAnimating()
                            
                            ModalService.showAlert(title: "Error", message: "Could not find account payment information for this profile; please contact support.", vc: self)
                        }
                    }
                }
                self.initUI()
            }.always{}
    }
    
    /// Navigates the user to the Update Payment page.
    /// - returns: Void
    /// - throws: No error.
    @objc private func addUpdateCard() -> Void {
        let paymentUpdateMethodViewController = storyBoard.instantiateViewController(withIdentifier: "PaymentUpdateMethodViewController") as! PaymentUpdateMethodViewController
        paymentUpdateMethodViewController.user = user
        navigationController!.pushViewController(paymentUpdateMethodViewController, animated: true)
    }
    
    @objc private func removeCard() -> Void {
        ModalService.showConfirm(title: "Delete Card?", message: "This card will be removed from your account and you can no longer make purchases on this card.", vc: self)
            .then{ () -> Void in
                self.spinner.isHidden = false
                self.spinner.startAnimating()
                StripeAPIClient.deleteCard(customerId: self.user.customerId, cardId: self.cardId)
                    .then{ response -> Void in
                        if let error = response.error {
                            print(error)
                            ModalService.showAlert(title: "Error", message: error.localizedDescription, vc: self)
                            
                            self.spinner.isHidden = true
                            self.spinner.stopAnimating()
                        }else{
                            if let JSON = response.result.value {
                                do{
                                    let json    : NSDictionary  = try JSONSerializer.toDictionary(JSON)
                                    print(json)
                                    
                                    //TODO: Json should look like this.
                                    //                                    Stripe\Object JSON: {
                                    //                                        "deleted": true,
                                    //                                        "id": "card_1BSvcWFxnf0DLuaiJW2WXLqA"
                                    //                                    }
                                    
                                    ModalService.showAlert(title: "Success", message: "Card was removed.", vc: self)
                                    
                                    self.spinner.isHidden = true
                                    self.spinner.stopAnimating()
                                    
                                    self.getCustomerInformation()
                                }catch let _ as NSError{
                                    ModalService.showAlert(title: "Error", message: "Could not find account payment information for this profile; please contact support.", vc: self)
                                    
                                    self.spinner.isHidden = true
                                    self.spinner.stopAnimating()
                                }
                            }else{
                                ModalService.showAlert(title: "Error", message: "Could not remove card at this time; please contact support.", vc: self)
                                
                                self.spinner.isHidden = true
                                self.spinner.stopAnimating()
                            }
                        }
                    }.always{}
            }.always{}
    }
    
}
