import UIKit

class UserCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var points: UILabel!
    @IBOutlet weak var betsWon: UILabel!
    @IBOutlet weak var gamesWon: UILabel!
    @IBOutlet weak var card: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
