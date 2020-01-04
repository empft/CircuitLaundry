import UIKit
import UserNotifications

class NotificationViewController: UITableViewController {

    @IBOutlet weak var myswitch: UISwitch!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.bool(forKey: "Notification") == true {
            myswitch.setOn(true, animated: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myswitch.addTarget(self, action: #selector(NotificationViewController.ToggleNotification), for: .valueChanged)
    
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
