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
}
