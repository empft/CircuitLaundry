import UIKit

class MachinesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var machineLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    
}

class ScanAddMachineViewController: UIViewController, LocationDelegateData, DelegateData, UITableViewDelegate, UITableViewDataSource {
 
    @IBOutlet weak var machineTableView: UITableView!
    @IBOutlet weak var locationLabel: UIButton!
    var stringarray: [String] = []
    var washercelldata: [(number: Int, code: String?)] = []
    var dryercelldata: [(number: Int, code: String?)] = []
    var celldata: [(number: Int, code: String?)] {
        return washercelldata + dryercelldata
    }
    var editwhichcode: Int? = nil
    var unifiedjson: UnifiedJson!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        machineTableView.delegate = self
        machineTableView.dataSource = self
        
        if let array = UserDefaults.standard.stringArray(forKey: "Laundry") {
            stringarray = array
            
        }
        
        self.locationRefresh()
    }

    func locationRefresh() {
        if stringarray.isEmpty {
            locationLabel.setTitle("Location", for: .normal)
        } else {
            locationLabel.setTitle(stringarray[2], for: .normal)
            (washercelldata, dryercelldata) = unifiedjson.machineData(stringarray: stringarray)
            self.machineTableView.reloadData()
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        if let json = createJsonFromArray() {
            let manager = ManageFile()
            manager.saveToFile(input: json)
            dismiss(animated: true, completion: nil)
        } else {
            print("Cannot convert Json to be saved")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scanaddsegue" {
            let vc = segue.destination as! PopoverViewController
            vc.stringarray = stringarray
            vc.send = 0
            vc.delegatelocation = self
        }
    }
    
    func createJsonFromArray() -> JSON? {
        let unifiedjson = UnifiedJson().json
        let i0 = Int(stringarray[3])!
        let i1 = Int(stringarray[4])!
        let i2 = Int(stringarray[5])!
        let name = stringarray[2]
        let webid: Int = unifiedjson!["Location"][i0]["Accommodation"][i1]["LaundryRoom"][i2]["WebId"].intValue
        var wash: [LaundretteList.washer] = []
        var dry: [LaundretteList.dryer] = []
        for tuple in washercelldata {
            wash.append(LaundretteList.washer(Number: tuple.number, Code: tuple.code))
        }
        for tuple in dryercelldata {
            dry.append(LaundretteList.dryer(Number: tuple.number, Code: tuple.code))
        }
        let laundry = LaundretteList(Laundrette: [LaundretteList.laundrette(WebId: webid, Name: name, Washer: wash, Dryer: dry)])
        if let json = try? JSONEncoder().encode(laundry) {
            return JSON(json)
        } else {
            return nil
        }
  
    }
    
    func passLocation(_ stringarray: [String]) {
        self.stringarray = stringarray
    }
    
    func pass(machine: String) {
        if let index = editwhichcode {
            let count = washercelldata.count
            if index < count {
                washercelldata[index].code = machine
            } else {
                dryercelldata[index-count].code = machine
            }
        }
    }
    
    //MARK: TableViewDelegate & Data
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return celldata.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.machineTableView.dequeueReusableCell(withIdentifier: "editmachinecell") as! MachinesTableViewCell
        
        func name() -> NSAttributedString {
            let washcount = washercelldata.count
            let index = indexPath.row
            let string = (index < washcount ? "Washer " : "Dryer ") + String(celldata[indexPath.row].number)
            let attr = index < washcount ? NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor: UIColor.blue]) : NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return attr
        }
        
        func code() -> String? {
            return celldata[indexPath.row].code
        }
        
        cell.machineLabel.attributedText = name()
        cell.codeLabel.text = code()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        editwhichcode = indexPath.row
        let modalvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QRScanner")
        self.present(modalvc, animated: true, completion: nil)
    }
}
