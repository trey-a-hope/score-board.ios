import UIKit

class FollowerCell: UITableViewCell {
    
    @IBOutlet weak var userName     : UILabel!
    @IBOutlet weak var userImage    : UIImageView!
    @IBOutlet weak var followBtn    : UIButton!
    @IBOutlet weak var unfollowBtn  : UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        followBtn.isHidden      = true
        unfollowBtn.isHidden    = true
        
    }
    
}
