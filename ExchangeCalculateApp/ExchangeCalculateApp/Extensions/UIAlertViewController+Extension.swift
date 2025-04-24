import UIKit

// MARK: UIAlertController Extension
extension UIAlertController {
    static func initErrorAlert(title: String, message: String) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default)
        alertController.addAction(okAction)
        return alertController
    }
}
