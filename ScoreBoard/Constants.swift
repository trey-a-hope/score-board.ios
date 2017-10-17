import UIKit

struct Constants {
    static let primaryColor: UIColor = GMColor.cyan800Color()
    static let primaryColorDark: UIColor = GMColor.cyan900Color()
    static let FONT_AWESOME_ATTRIBUTES: [NSAttributedStringKey : Any] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): UIFont.fontAwesome(ofSize: 20)]
    static let FONT_AWESOME_ATTRIBUTES_TABS: [NSAttributedStringKey : Any] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): UIFont.fontAwesome(ofSize: 30)]
    static let TABS_VERTICAL_OFFSET: CGFloat = -7
}
