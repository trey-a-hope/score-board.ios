import UIKit

class PaymentChargeCell: UITableViewCell {
    @IBOutlet weak var amount       : UILabel!
    @IBOutlet weak var _description : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}

