import UIKit

class MachineCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var machineLabel: UILabel!
    @IBOutlet weak var timeleftLabel: UILabel!
    var countdown: Int? = nil
    
    
    override func prepareForReuse() {
        machineLabel.text = nil
        timeleftLabel.text = nil
        countdown = nil
    }
    
}

class MachinesCollectionViewController: UICollectionViewController {
    
    private let reuseIdentifier = "MachineUseCell"
    var send: Int = -1
    fileprivate var washercelldata: [(number: Int, code: String?)] = []
    fileprivate var dryercelldata: [(number: Int, code: String?)] = []
    var json = try! JSON(data:(try! Data(contentsOf: Bundle.main.url(forResource: "MachineData", withExtension: "json")!)))  //chain multiple let because cant refer to other let here
    var unifiedjson: UnifiedJson!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ifLocationChanged()
    }
    
    func ifLocationChanged() {
        if let parent = self.parent as? MachinesViewController {
            if let stringarray = parent.currentstringarray {
                (washercelldata, dryercelldata) = unifiedjson.machineData(stringarray: stringarray)
            } else {
                washercelldata = []
                dryercelldata = []
            }
        } else if let parent = self.parent as? AvailabilityViewController {
           if let stringarray = parent.currentstringarray {
               (washercelldata, dryercelldata) = unifiedjson.machineData(stringarray: stringarray)
           } else {
               washercelldata = []
               dryercelldata = []
           }
        }
        
        self.collectionView.reloadData()
    }
    
    // MARK: UICollectionViewDataSource

    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch send {
        case 0 ,2:
            return washercelldata.count
        case 1 ,3:
            return dryercelldata.count
        default:
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MachineCollectionViewCell
        
        func setLabel(_ string: String,_ colour: UIColor) {
            let attr = NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor : colour])
            cell.machineLabel.attributedText = attr
        }
        
        func createCountdown(_ time: TimeInterval?) {
            if let time = time {
                cell.countdown = Int(time)
            }
        }
        
        cell.timeleftLabel.text = nil
        if send == 0 || send == 2 {
            let name = "Washer " + String(washercelldata[indexPath.item].number)
            let code = washercelldata[indexPath.item].code
            if send == 0 {
                setLabel(name, UIColor.blue)
            } else {
                if let code = code {
                    let parent = self.parent as! AvailabilityViewController
                        parent.api.getMachineInfo(of: code, completion: { available, time in
                            DispatchQueue.main.async {
                                if available {
                                    setLabel(name, UIColor.blue)
                                } else {
                                    setLabel(name, UIColor.gray)
                                    createCountdown(time)
                                }
                                
                            }
                        })
                } else {
                    setLabel(name + "\n Missing Number", UIColor.gray)
                }
            }
        } else if send == 1 || send == 3 {
            let name = "Dryer " + String(dryercelldata[indexPath.item].number)
            let code = dryercelldata[indexPath.item].code
            if send == 1 {
                setLabel(name, UIColor.red)
            } else {
                if let code = code {
                    let parent = self.parent as! AvailabilityViewController
                    parent.api.getMachineInfo(of: code, completion: { available, time in
                        DispatchQueue.main.async {
                            if available {
                                setLabel(name, UIColor.red)
                            } else {
                                setLabel(name, UIColor.gray)
                                createCountdown(time)
                            }
                        }
                    })
                } else {
                    setLabel(name + "\n Missing Number", UIColor.gray)
                }
            }
        }
        cell.layoutIfNeeded()
        return cell
    }
   
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if send == 0 || send == 1 {
            let number = send == 0 ? washercelldata[indexPath.item].number : dryercelldata[indexPath.item].number
            let code = send == 0 ? washercelldata[indexPath.item].code :  dryercelldata[indexPath.item].code
            if let parent = self.parent as? MachinesViewController {
                parent.useAlert(for: (number: number , code: code))
            }
        }
    }
   
}
