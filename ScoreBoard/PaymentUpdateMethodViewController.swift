import Material
import Stripe
import UIKit

class PaymentUpdateMethodViewController : UIViewController {
    @IBOutlet private weak var cardNumber   : TextField!
    @IBOutlet private weak var expMM        : TextField!
    @IBOutlet private weak var expYYYY      : TextField!
    @IBOutlet private weak var cvc          : TextField!
    @IBOutlet private weak var submitBtn    : UIButton!
    @IBOutlet private weak var spinner      : UIActivityIndicatorView!
    
    private var formIsValid                 : Bool = false
    public var user                         : User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    
    private func initUI() -> Void {
        spinner.isHidden = true
        
        hideKeyboardWhenTappedAround()
        
        //Default submit button to disabled.
        submitBtn.isEnabled = false
        submitBtn.alpha = 0.5;
        
        //Set text colors to determine valid/invalid inputs.
        cardNumber.dividerActiveColor = .red
        cardNumber.textColor = .red
        expMM.dividerActiveColor = .red
        expMM.textColor = .red
        expYYYY.dividerActiveColor = .red
        expYYYY.textColor = .red
        cvc.dividerActiveColor = .red
        cvc.textColor = .red
        
        //Add text field did change selectors.
        cardNumber.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        expMM.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        expYYYY.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        cvc.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        //Credit card number : 16-14 characters.
        if cardNumber.text?.count == 16 ||
            cardNumber.text?.count == 15 ||
            cardNumber.text?.count == 14 {
            cardNumber.dividerActiveColor = GMColor.green500Color()
            cardNumber.textColor = GMColor.green500Color()
            formIsValid = true
        }else{
            cardNumber.dividerActiveColor = .red
            cardNumber.textColor = .red
            formIsValid = false
        }
        //Expiration Month : 2 characters.
        if expMM.text?.count == 2 {
            expMM.dividerActiveColor = GMColor.green500Color()
            expMM.textColor = GMColor.green500Color()
            formIsValid = true
        }else{
            expMM.dividerActiveColor = .red
            expMM.textColor = .red
            formIsValid = false
        }
        //Expiration Year : 4 characters.
        if expYYYY.text?.count == 4 {
            expYYYY.dividerActiveColor = GMColor.green500Color()
            expYYYY.textColor = GMColor.green500Color()
            formIsValid = true
        }else{
            expYYYY.dividerActiveColor = .red
            expYYYY.textColor = .red
            formIsValid = false
        }
        //CVC : 3 characters.
        if cvc.text?.count == 3 {
            cvc.dividerActiveColor = GMColor.green500Color()
            cvc.textColor = GMColor.green500Color()
            formIsValid = true
        }else{
            cvc.dividerActiveColor = .red
            cvc.textColor = .red
            formIsValid = false
        }
        
        if formIsValid {
            submitBtn.isEnabled = true
            submitBtn.alpha = 1.0;
        }else{
            submitBtn.isEnabled = false
            submitBtn.alpha = 0.5;
        }
    }
    
    @IBAction func submit() -> Void {
        spinner.isHidden = false
        spinner.startAnimating()
        
        // Initiate the card
        let stripeCard: STPCardParams = STPCardParams()
        
        // Send the card info to Strip to get the token
        stripeCard.number = cardNumber.text
        stripeCard.cvc = cvc.text
        stripeCard.expMonth = UInt(expMM.text!)!
        stripeCard.expYear = UInt(expYYYY.text!)!
        
        STPAPIClient.shared().createToken(withCard: stripeCard, completion: {(token, error) -> Void in
            if let error = error {
                self.spinner.isHidden = true
                self.spinner.stopAnimating()
                ModalService.showAlert(title: "Error", message: error.localizedDescription, vc: self)
            }
            else if let token = token {
                print(token.tokenId)
                StripeAPIClient.updateCustomer(customerId: self.user.customerId, description: "New card added.", token: token.tokenId)
                    .then{ response -> Void in
                        if let error = response.error {
                            ModalService.showAlert(title: "Error", message: error.localizedDescription, vc: self)
                        }else{
                            if let JSON = response.result.value {
                                do{
                                    let json    : NSDictionary  = try JSONSerializer.toDictionary(JSON)
                                    let soures  : NSDictionary  = json["sources"] as! NSDictionary
                                    let cards   : NSArray       = soures["data"] as! NSArray
                                    //If card count is more than 0, card was added successfully.
                                    if cards.count > 0 {
                                        ModalService.showAlert(title: "Success", message: "Card Added", vc: self)
                                    }else{
                                        ModalService.showAlert(title: "Error", message: "Could not add card at this time, please try again later or contact support.", vc: self)
                                    }
                                }catch let _ as NSError{
                                    ModalService.showAlert(title: "Error", message: "Could not add card at this time, please try again later or contact support.", vc: self)
                                }
                            }
                        }
                    }.always{
                        self.spinner.isHidden = true
                        self.spinner.stopAnimating()
                }
            }
        })
    }
    
}
