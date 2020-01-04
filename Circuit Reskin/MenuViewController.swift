import UIKit

class MenuTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func logout() {
        let actionmenu = UIAlertController(title: nil , message: "Are you sure you want to log out?", preferredStyle: .actionSheet)
        let logout = UIAlertAction(title: "Logout", style: .destructive, handler: { action in
            UserDefaults.standard.removeObject(forKey: "token")
            let main = UIStoryboard(name: "Main", bundle: nil)
            let view = main.instantiateViewController(withIdentifier: "LoginScreen")
            UIApplication.shared.keyWindow?.rootViewController = view
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionmenu.addAction(cancel)
        actionmenu.addAction(logout)
        self.present(actionmenu, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
        if indexPath.section == 1 && indexPath.row == 0 {
                self.logout()
        }
    }
}

class MenuViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    
}

