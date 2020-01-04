import UIKit

class InstructionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    @IBAction func finishReadingInstruction(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "instruction")
        var loginstate = false
        if UserDefaults.standard.string(forKey: "token") != nil {
            loginstate = true
        }
        if !loginstate {
            let mainstoryboard = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginScreen")
            UIApplication.shared.keyWindow?.rootViewController = mainstoryboard
        } else {
            let mainstoryboard = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeScreen")
            UIApplication.shared.keyWindow?.rootViewController = mainstoryboard
        }
    }
}
