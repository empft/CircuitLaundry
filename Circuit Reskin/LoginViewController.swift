import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    //MARK: Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    //MARK: Action
    @IBAction func loginAction(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            if !email.isEmpty && !password.isEmpty {
                let login = ApiWithoutSession(email: email, password: password)
                login.userLogin()
            } else {
                alertError("Email address/Password cannot be left blank")
            }
        }
    }
    
    @IBAction func unwindToLogin(unwindsegue: UIStoryboardSegue) {
    }


}

