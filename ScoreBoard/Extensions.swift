import UIKit

extension UIImageView {
    func round(borderWidth: CGFloat, borderColor: UIColor) -> Void {
        //Round image
        layer.cornerRadius = frame.size.width / 2;
        clipsToBounds = true;
        //Add border
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
    }
}

extension UIApplication {
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
}

extension UIColor {
    func random() -> UIColor {
        let r:CGFloat = CGFloat(arc4random_uniform(255)) / 255.0
        let g:CGFloat = CGFloat(arc4random_uniform(255)) / 255.0
        let b:CGFloat = CGFloat(arc4random_uniform(255)) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    //Always pass FFFFFF, not #FFFFFF
    func hexStringToUIColor(hex:String) -> UIColor {
//        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
//        if (cString.hasPrefix("#")) {
//            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
//        }
        
        if ((hex.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: hex).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

//https://forbrains.co.uk/international_tools/earth_timezones
extension Date {
    //TODO: Verify this gives the correct timezone offset in November.
    func getTimeZoneOffset() -> Int {
        let seconds: Int = TimeZone.current.secondsFromGMT()
        var minutes: Int = seconds/60
        
        return abs(minutes)
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    var storyBoard: UIStoryboard {
        return UIStoryboard(name: "Main", bundle:nil)
    }
}

extension Int {
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
}

extension String {
    var doubleValue: Double? {
        return Double(self)
    }
    
    var floatValue: Float? {
        return Float(self)
    }
    
    var integerValue: Int? {
        return Int(self)
    }
    
    func currencyInputFormatting() -> String {
        
        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        var amountWithPrefix = self
        
        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count), withTemplate: "")
        
        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double / 100))
        
        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return ""
        }
        
        return formatter.string(from: number)!
    }
}
