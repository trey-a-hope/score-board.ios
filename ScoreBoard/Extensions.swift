import UIKit

extension UIImageView {
    func round(_ borderWidth: CGFloat, _ borderColor: UIColor) -> Void {
        //Round image.
        self.layer.cornerRadius = self.frame.size.width / 2;
        self.clipsToBounds = true;
        //Add border.
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
    }
}

extension UIColor {
    func random() -> UIColor {
        let r:CGFloat = CGFloat(arc4random_uniform(255)) / 255.0
        let g:CGFloat = CGFloat(arc4random_uniform(255)) / 255.0
        let b:CGFloat = CGFloat(arc4random_uniform(255)) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}

extension Date {
    func getTimeZoneOffset() -> Int {
        let seconds: Int = TimeZone.current.secondsFromGMT()
        let minutes: Int = seconds/60
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
}
