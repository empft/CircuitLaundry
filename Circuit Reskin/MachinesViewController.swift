import UIKit
import UserNotifications

class MachinesViewController: UIViewController, UIScrollViewDelegate ,DelegateData , RefreshDelegate {
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var scrollingView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var refcgrect: CGRect!
    var isRefresh: Bool = false
    var api: ApiWithSession!
    var pagearray: [[String]] = []
    var currentstringarray: [String]? = nil
    var pagecount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refcgrect = contentView.frame
        let tabbar = self.tabBarController as! TabBarViewController
        api = tabbar.tabbarapi
        
        view.addGestureRecognizer(scrollingView.panGestureRecognizer)
        scrollingView.delegate = self
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let number = round(scrollView.contentOffset.x / refcgrect.width)
        pagecount = Int(number)
        print(scrollView.contentOffset.x)
        print(scrollView.contentOffset.y)
        
        self.locationRefresh()
    }
    
    func pageInitialize() {
        
        func setLocationNull() {
            let label = UILabel()
            label.text = "No Location"
            label.frame = CGRect(x: 0, y: 0, width: refcgrect.width, height: refcgrect.height)
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            scrollingView.contentSize = refcgrect.size
            contentView.addSubview(label)
        }
        
        contentView.subviews.forEach({ ($0 as? UILabel)?.removeFromSuperview() })
        
        if let page = UserDefaults.standard.array(forKey: "Page") as? [[String]] {
            pagearray = page
            
            
            let width = refcgrect.width*CGFloat(pagearray.count)
            let height = refcgrect.height
            scrollingView.contentSize = CGSize(width: width, height: height)
            if pagearray != [] {
                let refframe = CGRect(x: 0, y: 0, width: refcgrect.width, height: refcgrect.height)
                for (index, arr) in page.enumerated() {
                    
                    let dx = refframe.width*CGFloat(index)
                    let frame = refframe.offsetBy(dx: dx, dy: 0)
                    let label = UILabel(frame: frame)
                    label.text = arr[2]
                    label.textAlignment = .center
                    label.adjustsFontSizeToFitWidth = true
                    contentView.addSubview(label)
        
                }
            } else {
                setLocationNull()
            }
        } else {
            setLocationNull()
        }

    }

 
   
    func locationRefresh() {
        pageInitialize()
        pageControl.numberOfPages = pagearray.count
        pageControl.currentPage = pagecount
        
        if pagearray == [] {
            currentstringarray = nil
        } else {
            currentstringarray = pagearray[pagecount]
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
        let code = tuple.code ?? "Missing Code"
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
            vc.pagecount = self.pagecount
        } else if segue.identifier == "UseMachineQRSegue" {
            let vc = segue.destination as! QRScannerViewController
            vc.delegate = self
        } else if segue.identifier == "quickaccess0" {
            let vc = segue.destination as! PopoverViewController
            vc.send = 1
            vc.delegaterefresh = self
        }
    }
    
    @IBAction func plusAction(_ sender: Any) {
        let actionmenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let firstchoice = UIAlertAction(title: "Save Machine Number", style: .default, handler: { action in
           if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "scanaddvc") as? ScanAddMachineViewController {
                vc.delegate = self
                let tabbarvc = self.tabBarController as! TabBarViewController
                vc.unifiedjson = tabbarvc.unifiedjson
                vc.pagecount = self.pagecount
                self.present(vc, animated: true, completion: nil)
            }
        })
        let secondchoice = UIAlertAction(title: "Add Laundry Room", style: .default, handler: { action in
            self.performSegue(withIdentifier: "quickaccess0", sender: nil)
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancel.setValue(UIColor.red, forKey: "titleTextColor")
        actionmenu.addAction(firstchoice)
        actionmenu.addAction(secondchoice)
        actionmenu.addAction(cancel)
        self.present(actionmenu, animated: true, completion: nil)
    }
    
}
