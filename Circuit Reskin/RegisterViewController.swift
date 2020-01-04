import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate, DelegateData {
    

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var scanQR: UIButton!
    @IBOutlet weak var skipQR: UIButton!
    
    var machineText: String? = nil
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RegisterQRSegue" {
            let destvc = segue.destination as! QRScannerViewController
           
            destvc.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let borderGrey = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1).cgColor
        scanQR.layer.borderColor = borderGrey
        scanQR.layer.borderWidth = 0.5
        scanQR.layer.cornerRadius = 5
        
        skipQR.layer.borderColor = borderGrey
        skipQR.layer.borderWidth = 0.5
        skipQR.layer.cornerRadius = 5
        
        self.hideKeyboardWhenTapped()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        }
        return true
    }
    
    func pass(machine: String) {
        machineText = machine
    }
    
    @IBAction func skipQRAction(_ sender: Any) {
        let arrayOfCode = ["LKPMKSZ0", "JZ8RX2LE", "VXEMBIFW", "NZ2YSDIX", "10Z010L2", "4GVG9HLH", "F2PU36LH", "LEJ4ZQFC", "9LEII7UU", "1K5PZJRO"]
        let skipalert = UIAlertController(title: "Skip Scanning", message: "For unknown reason, Circuit requires user to provide machine number when signing up. If you choose to skip this step, we will use one of the stored number.", preferredStyle: .alert)
        skipalert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        skipalert.addAction(UIAlertAction(title: "Skip", style: .default, handler: {action in
            let random = arrayOfCode.randomElement()!
            self.machineText = random
            self.scanQR.isEnabled = false
            self.scanQR.setTitle(random, for: .disabled)
        }))
        self.present(skipalert, animated: true, completion: nil)
    }
    @IBAction func signUpAction(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text, let machine = machineText {
            if !email.isEmpty && !password.isEmpty && !machine.isEmpty {
                let signup = ApiWithoutSession(email: email, password: password, machine: machine)
                signup.createUser()
            } else {
                alertError("QRCode/Email Address/Password cannot be left blank")
            }
        }
    }
}

