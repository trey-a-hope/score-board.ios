import UIKit

class PaymentHistoryDetailsViewController : UIViewController {
    @IBOutlet private weak var amount       : UILabel!
    @IBOutlet private weak var _description : UILabel!
    @IBOutlet private weak var date         : UILabel!
    
    public var charge                       : Charge!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    private func initUI() -> Void {
        amount.text = String(format: "$%.02f", charge.amount!)
        _description.text = charge.description
        date.text = ConversionService.convertDateToString(charge.timestamp, DateFormatter.Style.full)
    }
}

