import UIKit

class AvailabilityViewController: UIViewController, RefreshDelegate {

    @IBOutlet weak var locationLabel: UIButton!
    var timer: Timer?
    var api: ApiWithSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationRefresh()
        let tabbar = self.tabBarController as! TabBarViewController
        api = tabbar.tabbarapi
        
        NotificationCenter.default.addObserver(self, selector: #selector(AvailabilityViewController.viewDidAppear), name: UIApplication.willEnterForegroundNotification, object: nil)

        
        let options = NSKeyValueObservingOptions([.new, .old, .initial, .prior])
        self.locationLabel.addObserver(self, forKeyPath: "titleLabel.text", options: options, context: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        locationRefresh()
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.locationRefresh()
        self.startTimer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.stopTimer()
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
    
    func startTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(AvailabilityViewController.updateTimer), userInfo: nil, repeats: true)
        }
    }
    
    func stopTimer() {
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
    }
    
    @objc func updateTimer() {
        for child in self.children {
            for cell in (child as! MachinesCollectionViewController).collectionView.visibleCells {
                if let cell = cell as? MachineCollectionViewCell {
                    if let count = cell.countdown {
                        if count > 0 {
                            let min = count/60
                            let sec = count % 60
                            cell.timeleftLabel.isHidden = false
                            if sec < 10 {
                                cell.timeleftLabel.text = "\(min):0\(sec)"
                            } else {
                                cell.timeleftLabel.text = "\(min):\(sec)"
                            }
                            cell.countdown! -= 1
                        }
                    }
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tabbarvc = self.tabBarController as! TabBarViewController
        if segue.identifier == "availabilitywasher" {
            let vc = segue.destination as! MachinesCollectionViewController
            vc.send = 2
            vc.unifiedjson = tabbarvc.unifiedjson
        } else if segue.identifier == "availabilitydryer" {
            let vc = segue.destination as! MachinesCollectionViewController
            vc.send = 3
            vc.unifiedjson = tabbarvc.unifiedjson
        } else if segue.identifier == "scanaddsegue1" {
            let vc = segue.destination as! ScanAddMachineViewController
            vc.unifiedjson = tabbarvc.unifiedjson
        } else if segue.identifier == "popoversegue1" {
            let vc = segue.destination as! PopoverViewController
            vc.delegaterefresh = self
        }
    }
    
    func refresh() {
        for child in self.children {
            if let child = child as? MachinesCollectionViewController {
                child.ifLocationChanged()
                child.collectionView.reloadData()
            }
        }
    }
}
