import UIKit

extension UIViewController {
	func displayError(title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let okAction = UIAlertAction(title: "Ok", style: .default)
		alert.addAction(okAction)
		self.present(alert, animated: true, completion: nil)
	}
}
