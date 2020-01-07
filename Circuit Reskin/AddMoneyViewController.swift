import UIKit
import SafariServices

class AddMoneyViewController: UIViewController, UITextFieldDelegate {

    let api = ApiWithSession()
    @IBOutlet weak var currencyTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currencyTextField.delegate = self
        currencyTextField.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)
        self.hideKeyboardWhenTapped()
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(AddMoneyViewController.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(AddMoneyViewController.cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        currencyTextField.inputAccessoryView = toolBar
    }
    
    @objc func cancelClick() {
        currencyTextField.resignFirstResponder()
    }
    
    @objc func doneClick() {
        processAction(self)
    }
    
    @objc func myTextFieldDidChange(_ textField: UITextField) {
        
        if let amountString = textField.text?.currencyInputFormatting() {
            textField.text = amountString
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        currencyTextField.resignFirstResponder()
        self.processAction(currencyTextField as Any)
        
        return true
    }
    
    func readCurrency() -> (string :String, double: Double) {
        if let money = currencyTextField.text  {
            if money != "" {
                var moneystr = String(money.dropFirst())
                moneystr = moneystr.replacingOccurrences(of: ",", with: "")
                return (string: moneystr, double: Double(moneystr)!)
            } else {
                return (string: "0", double: 0)
            }
        } else {
            return (string: "0", double: 0)
        }
    }
    
    func doTransaction() {
        api.addMoney(with: readCurrency().string, completion: {
            url in
            let formattedurl = URL(string: url)!
            let safari = SFSafariViewController(url: formattedurl)
            self.present(safari, animated: true, completion: nil)
        })
    }

    @IBAction func processAction(_ sender: Any) {
        if self.readCurrency().double >= 5 {
            doTransaction()
        } else {
            print("Invalid Amount")
        }
    }

}

fileprivate extension String {
    
    // formatting text for currency textField
    func currencyInputFormatting() -> String {
        
        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.currencySymbol = "£"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        var amountWithPrefix = self
        
        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count), withTemplate: "")
        
        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double / 100))
        
        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return ""
        }
        
        return formatter.string(from: number)!
    }
}
