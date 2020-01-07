import UIKit

class AvailabilityViewController: UIViewController, UIScrollViewDelegate, RefreshDelegate {

    @IBOutlet weak var scrollingView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var contentView: UIView!
    
    var refcgrect: CGRect!
    var timer: Timer?
    var api: ApiWithSession!
    var pagearray: [[String]] = []
    var currentstringarray: [String]? = nil
    var pagecount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refcgrect = contentView.frame
        locationRefresh()
        let tabbar = self.tabBarController as! TabBarViewController
        api = tabbar.tabbarapi
        
        NotificationCenter.default.addObserver(self, selector: #selector(AvailabilityViewController.viewDidAppear), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        view.addGestureRecognizer(scrollingView.panGestureRecognizer)
        scrollingView.delegate = self
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let number = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pagecount = Int(number)
        
        self.locationRefresh()
    }
    
     func pageInitialize() {
             
             func setLocationNull() {
                 let label = UILabel()
                 label.text = "No Location"
                 label.frame = CGRect(x: 0, y: 0, width: refcgrect.width, height: refcgrect.height)
                 label.textAlignment = .center
                 label.adjustsFontSizeToFitWidth = true
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
            vc.pagecount = self.pagecount
        } else if segue.identifier == "quickaccess1" {
            let vc = segue.destination as! PopoverViewController
            vc.send = 1
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
    
    @IBAction func plusAction(_ sender: Any) {
        let actionmenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let firstchoice = UIAlertAction(title: "Save Machine Number", style: .default, handler: { action in
               if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "scanaddvc") as?   ScanAddMachineViewController {
                    vc.delegate = self
                    let tabbarvc = self.tabBarController as! TabBarViewController
                    vc.unifiedjson = tabbarvc.unifiedjson
                    vc.pagecount = self.pagecount
                    self.present(vc, animated: true, completion: nil)
                }
        })
        let secondchoice = UIAlertAction(title: "Add Laundry Room", style: .default, handler: { action in
            self.performSegue(withIdentifier: "quickaccess1", sender: nil)
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionmenu.addAction(firstchoice)
        actionmenu.addAction(secondchoice)
        actionmenu.addAction(cancel)
        self.present(actionmenu, animated: true, completion: nil)
    }
    
}
