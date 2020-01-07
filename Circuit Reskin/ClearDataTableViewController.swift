import UIKit

class ClearDataTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         if indexPath.row == 0 {
             deleteData(isLocation: true)
         } else if indexPath.row == 1 {
             deleteData(isLocation: false)
         }
     }
    
    func deleteData(isLocation: Bool) {
        
        func resetPageCount() {
            let navigaterootvc = self.navigationController?.viewControllers.first
            if let tabbarvc = navigaterootvc?.tabBarController as? TabBarViewController {
                for child in tabbarvc.children {
                    if let vc = child as? MachinesViewController {
                        vc.pagecount = 0
                        vc.locationRefresh()
                        
                    } else if let vc = child as? AvailabilityViewController {
                        vc.pagecount = 0
                        vc.locationRefresh()
                    }
                }
            }
        }
        
        func resetNumber() {
            let navigaterootvc = self.navigationController?.viewControllers.first
            if let tabbarvc = navigaterootvc?.tabBarController as? TabBarViewController {
                tabbarvc.unifiedjson.updateJsonValue()
            }
            
        }
        
        let alertvc: UIAlertController
        let yes: UIAlertAction
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancel.setValue(UIColor.red, forKey: "titleTextColor")
        
        if isLocation {
            alertvc = UIAlertController(title: nil, message: nil , preferredStyle: .actionSheet)
            yes = UIAlertAction(title: "Delete all locations", style: .default, handler: { action in
                UserDefaults.standard.set([], forKey: "Page")
                resetPageCount()
            })
            let latest = UIAlertAction(title: "Delete the most recent location", style: .default, handler: { action in
                if let arr = UserDefaults.standard.object(forKey: "Page") as? [[String]] {
                    if arr != [] {
                        let exist: [[String]] = arr.dropLast()
                        UserDefaults.standard.set(exist, forKey: "Page")
                        
                    } else {
                        UserDefaults.standard.set([], forKey: "Page")
    
                    }
                    resetPageCount()
                }
            })
            alertvc.addAction(latest)
            
        } else {
            alertvc = UIAlertController(title: "Confirmation" , message: "Are you sure you want to delete all saved machine numbers", preferredStyle: .actionSheet)
            yes = UIAlertAction(title: "Yes", style: .default, handler: { action in
                let filemanager = ManageFile()
                filemanager.deleteEverything()
                resetNumber()
            })
        }
        alertvc.addAction(cancel)
        alertvc.addAction(yes)
        self.present(alertvc, animated: true, completion: nil)
    }
}
