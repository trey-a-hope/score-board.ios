import UIKit

protocol FormProtocol {
    /// Returns true if the form is complete properly.
    /// - returns: Bool - valid or not.
    /// - throws: No error.
    func formIsValid() -> Bool
    
    /// Detects any changes on the text fields of the form.
    /// - returns: Void - nothing.
    /// - throws: No error.
    func textFieldDidChange(_ textField: UITextField) -> Void
    /// Clears all text fields.
    /// - returns: Void - nothing.
    /// - throws: No error.
    func clearForm() -> Void
}


