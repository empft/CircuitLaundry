import UIKit
import UserNotifications

class MachinesViewController: UIViewController, DelegateData, RefreshDelegate {
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var locationLabel: UIButton!
    var isRefresh: Bool = false
    var api: ApiWithSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tabbar = self.tabBarController as! TabBarViewController
        api = tabbar.tabbarapi
        
        locationRefresh()
        
        let options = NSKeyValueObservingOptions([.new, .old, .initial, .prior])
            self.locationLabel.addObserver(self, forKeyPath: "currentTitle", options: options, context: nil)
    }
        
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        locationRefresh()
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        api.getBalance(completion: { amount in
            
            let amountstr = String(format: "%.2f", amount)
            self.balanceLabel.text = "£" + amountstr
            if amount < 5 {
                self.balanceLabel.textColor = UIColor.red
            } else {
                if #available(iOS 13.0, *) {
                    self.balanceLabel.textColor = UIColor.label
                } else {
                    self.balanceLabel.textColor = UIColor.black
                }
            }
        })
        self.locationRefresh()
    }
    
    func locationRefresh() {
        if let loc = UserDefaults.standard.stringArray(forKey: "Laundry") {
            let text = NSMutableAttributedString(string: loc[2])
            let attrs = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.patternDot.rawValue | NSUnderlineStyle.single.rawValue]
            text.addAttributes(attrs, range: NSRange(location: 0, length: text.length))
            locationLabel.setAttributedTitle(text, for: .normal)
        } else {
            let text = NSMutableAttributedString(string: "Location")
            let attrs = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.patternDot.rawValue | NSUnderlineStyle.single.rawValue]
            text.addAttributes(attrs, range: NSRange(location: 0, length: text.length))
            locationLabel.setAttributedTitle(text, for: .normal)
        }
        self.refresh()
        
    }
    
    func refresh() {
        for child in self.children {
            if let child = child as? MachinesCollectionViewController {
                child.ifLocationChanged()
                child.collectionView.reloadData()
            }
        }
    }
    
    func scheduleNotification() -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Laundry"
        content.body = "Washer/ Dryer is done"
        content.sound = .default
        return content
    }
    
    func usemachine(machine: String) {
        api.useMachine(of: machine, completion: { time in
            if UserDefaults.standard.bool(forKey: "Notification") == true {
                let center = UNUserNotificationCenter.current()
                center.getNotificationSettings(completionHandler: {settings in
                    guard settings.authorizationStatus == .authorized else {return}
                    if settings.alertSetting == .enabled {
                        if let time = time {
                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: time, repeats: false)
                            let request = UNNotificationRequest(identifier: "Laundry", content: self.scheduleNotification(), trigger: trigger)
                            center.add(request, withCompletionHandler: { (error) in
                            if let error = error {
                                print(error)
                            }
                            })
                        }
                    }
                    
                })
            }
        })
    }
    
    func pass(machine: String) {
        self.usemachine(machine: machine)
    }
    
    func useAlert(for tuple:(number: Int, code: String?)) {
        let code = tuple.code ?? "Not Available"
        let alert = UIAlertController(title: nil, message: "Are you sure you want to use machine \(String(tuple.number)) with code \(code)?", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .default, handler: {action in
            if tuple.code != nil{
                self.usemachine(machine: code)
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        alert.addAction(yes)
        self.present(alert ,animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tabbarvc = self.tabBarController as! TabBarViewController
        if segue.identifier == "usemachinewasher" {
            let vc = segue.destination as! MachinesCollectionViewController
            vc.send = 0
            vc.unifiedjson = tabbarvc.unifiedjson
        } else if segue.identifier == "usemachinedryer" {
            let vc = segue.destination as! MachinesCollectionViewController
            vc.send = 1
            vc.unifiedjson = tabbarvc.unifiedjson
        } else if segue.identifier == "scanaddsegue0" {
            let vc = segue.destination as! ScanAddMachineViewController
            vc.unifiedjson = tabbarvc.unifiedjson
        } else if segue.identifier == "UseMachineQRSegue" {
            let vc = segue.destination as! QRScannerViewController
            vc.delegate = self
        } else if segue.identifier == "popoversegue0" {
            let vc = segue.destination as! PopoverViewController
            vc.delegaterefresh = self
        }
    }
    
}
