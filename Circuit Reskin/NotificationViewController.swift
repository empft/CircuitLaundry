import UIKit
import UserNotifications

class NotificationViewController: UITableViewController, UITextFieldDelegate {
  

    @IBOutlet weak var myswitch: UISwitch!
    @IBOutlet weak var timeInputField: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.bool(forKey: "Notification") {
            myswitch.setOn(true, animated: false)
        }
        
        let time = UserDefaults.standard.double(forKey: "Time")
        timeInputField.text = "\(time)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myswitch.addTarget(self, action: #selector(NotificationViewController.ToggleNotification), for: .valueChanged)
        
        timeInputField.delegate = self
        
        self.hideKeyboardWhenTapped()
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
               
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(NotificationViewController.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(NotificationViewController.cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        timeInputField.inputAccessoryView = toolBar
        timeInputField.adjustsFontSizeToFitWidth = true
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        timeInputField.resignFirstResponder()
        self.processAction()
        return true
    }
    
    func processAction() {
        if let text = timeInputField.text {
            if let time = Double(text) {
                UserDefaults.standard.set(time, forKey: "Time")
            }
        }
    }

    @objc func cancelClick() {
        timeInputField.resignFirstResponder()
    }
    
    @objc func doneClick() {
        timeInputField.resignFirstResponder()
        self.processAction()
    }
    
    @objc func ToggleNotification() {
        if myswitch.isOn {
            let center = UNUserNotificationCenter.current()
            if UserDefaults.standard.object(forKey: "Notification") == nil {
                center.requestAuthorization(options: [.alert, .sound], completionHandler: {    granted, error in
                    if !granted {
                        print("User disallow Notification")
                        self.myswitch.setOn(false, animated: true)
                        return
                    }
                })
            }
            UserDefaults.standard.set(true, forKey: "Notification")
        } else {
            UserDefaults.standard.set(false, forKey: "Notification")
        }
    }
}
