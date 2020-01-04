import UIKit

extension UIViewController {
    func hideKeyboardWhenTapped() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIViewController {
    func alertError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alert.addAction(dismiss)
        self.present(alert, animated: true, completion: nil)
    }
}

fileprivate struct MachineTreeData: Decodable {
    let Location: [location]
    
    struct location: Decodable {
        let WebId: Int
        let Name: String
        let Accommodation: [accommodation]
    }
    
    struct accommodation: Decodable {
        let WebId: Int
        let Name: String
        let LaundryRoom: [laundryroom]
    }
    
    struct laundryroom: Decodable {
        let WebId: Int
        let Name: String
        let Washer: [washer]
        let Dryer: [dryer]
    }
    
    struct washer: Decodable {
        let Number: Int
        let Code: String?
    }
    
    struct dryer: Decodable {
        let Number: Int
        let Code: String?
    }
}
