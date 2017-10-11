import UIKit

class GameCell: UICollectionViewCell {
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var homeTeamImage: UIImageView!
    @IBOutlet weak var homeTeamScore: UILabel!
    @IBOutlet weak var awayTeamImage: UIImageView!
    @IBOutlet weak var awayTeamScore: UILabel!
    @IBOutlet weak var potAmount: UILabel!
}
