import UIKit

struct Constants {
    //Colors
    static let primaryColor: UIColor = GMColor.red800Color()
    static let primaryColorDark: UIColor = GMColor.red900Color()
    
    //Font Awesome
    static let FONT_AWESOME_ATTRIBUTES: [NSAttributedStringKey : Any] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): UIFont.fontAwesome(ofSize: 20)]
    static let FONT_AWESOME_ATTRIBUTES_TABS: [NSAttributedStringKey : Any] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): UIFont.fontAwesome(ofSize: 30)]
    
    //Tabs
    static let TABS_VERTICAL_OFFSET: CGFloat = -7
    
    //UITableView Cell Height
    static let FOLLOWER_CELL_HEIGHT : CGFloat = CGFloat(70)
    static let GAME_CELL_HEIGHT     : CGFloat = CGFloat(100)
    
    //New User
    static let DEFAULT_IMAGE_URL: String = "http://www.techweez.com/wp-content/uploads/2017/07/NO-IMAGE.png"
}
