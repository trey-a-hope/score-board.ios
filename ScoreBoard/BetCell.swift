import UIKit

class BetCell: UICollectionViewCell {
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var homeTeamImage: UIImageView!
    @IBOutlet weak var homeTeamDigit: UILabel!
    @IBOutlet weak var awayTeamImage: UIImageView!
    @IBOutlet weak var awayTeamDigit: UILabel!
    @IBOutlet weak var posted: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
