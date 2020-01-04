import UIKit

class TabBarViewController: UITabBarController {
    var tabbarapi = ApiWithSession()
    var unifiedjson = UnifiedJson()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewControllers?.forEach { let _ = $0.view }
    }
}
