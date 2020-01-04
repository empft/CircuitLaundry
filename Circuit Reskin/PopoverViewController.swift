import UIKit

protocol LocationDelegateData: AnyObject {
    func passLocation(_ stringarray: [String])
    func locationRefresh()
}

protocol RefreshDelegate: AnyObject {
    func locationRefresh()
}

class PopoverViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var accommodationTextField: UITextField!
    @IBOutlet weak var laundretteTextField: UITextField!
    @IBOutlet weak var selectLabel: UIBarButtonItem!
    var myPickerView = UIPickerView()
    var stringarray: [String] = []
    var send: Int = -1
    
    
    let json = try! JSON(data:(try! Data(contentsOf: Bundle.main.url(forResource: "MachineData", withExtension: "json")!)))  //chain multiple let because cant refer to other let here
    
    lazy var locationlist: [String] = json["Location"].arrayValue.map{$0["Name"].stringValue}
    var accommodationlist: [String] = []
    var laundryroomlist: [String] = []
    
    weak var delegatelocation: LocationDelegateData? = nil
    weak var delegaterefresh: RefreshDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTapped()
        
        accommodationTextField.isEnabled = false
        laundretteTextField.isEnabled = false
        
        locationTextField.delegate = self
        accommodationTextField.delegate = self
        laundretteTextField.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == locationTextField {
            pickUp(locationTextField)
        } else if textField == accommodationTextField {
            pickUp(accommodationTextField)
        } else if textField == laundretteTextField {
            pickUp(laundretteTextField)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == locationTextField {
            accommodationTextField.isEnabled = true
            laundretteTextField.isEnabled = false
            accommodationTextField.text = nil
            laundretteTextField.text = nil
        } else if textField == accommodationTextField {
            laundretteTextField.isEnabled = true
            laundretteTextField.text = nil
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return  1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if locationTextField.isFirstResponder {
            return locationlist.count
        } else if accommodationTextField.isFirstResponder {
            return accommodationlist.count
        } else if laundretteTextField.isFirstResponder {
            return laundryroomlist.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if locationTextField.isFirstResponder {
            return locationlist[row]
        } else if accommodationTextField.isFirstResponder {
            return accommodationlist[row]
        } else if laundretteTextField.isFirstResponder {
            return laundryroomlist[row]
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if locationTextField.isFirstResponder {
            locationTextField.text = locationlist[row]
            accommodationlist = json["Location"][row]["Accommodation"].arrayValue.map{$0["Name"].stringValue}
        } else if accommodationTextField.isFirstResponder {
            accommodationTextField.text = accommodationlist[row]
            let row0 = locationlist.firstIndex(of: locationTextField.text!)!
            laundryroomlist = json["Location"][row0]["Accommodation"][row]["LaundryRoom"].arrayValue.map{$0["Name"].stringValue}
        } else if laundretteTextField.isFirstResponder {
            laundretteTextField.text = laundryroomlist[row]
        }
    }
    
    func pickUp(_ textField : UITextField){
        
        // UIPickerView
        self.myPickerView = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.myPickerView.delegate = self
        self.myPickerView.dataSource = self
        if #available(iOS 13.0, *) {
            self.myPickerView.backgroundColor = UIColor.systemBackground
        } else {
            self.myPickerView.backgroundColor = UIColor.white
        }
        textField.inputView = self.myPickerView
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(PopoverViewController.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(PopoverViewController.cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
        
        self.myPickerView.selectRow(0, inComponent: 0, animated: true)
        self.pickerView(myPickerView, didSelectRow: 0, inComponent: 0)
    }
    
    @objc func doneClick() {
        if locationTextField.isFirstResponder {
            locationTextField.resignFirstResponder()
            accommodationTextField.becomeFirstResponder()
        } else if accommodationTextField.isFirstResponder {
            accommodationTextField.resignFirstResponder()
            laundretteTextField.becomeFirstResponder()
        } else if laundretteTextField.isFirstResponder {
            laundretteTextField.resignFirstResponder()
            selectAction(selectLabel as Any)
        }
    }
    
    @objc func cancelClick() {
        if locationTextField.isFirstResponder {
            locationTextField.resignFirstResponder()
        } else if accommodationTextField.isFirstResponder {
            accommodationTextField.resignFirstResponder()
        } else if laundretteTextField.isFirstResponder {
            laundretteTextField.resignFirstResponder()
        }
    }

    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func selectAction(_ sender: Any) {
        if let text1 = locationTextField.text, let text2 = accommodationTextField.text, let text3 = laundretteTextField.text, text3 != "", text2 != "", text1 != "" {
            let num1 = String(locationlist.firstIndex(of: text1)!)
            let num2 = String(accommodationlist.firstIndex(of: text2)!)
            let num3 = String(laundryroomlist.firstIndex(of: text3)!)
            let array = [text1,text2,text3,num1,num2,num3]
            if send == -1 {
                UserDefaults.standard.set(array, forKey: "Laundry")
                delegaterefresh?.locationRefresh()
                
            } else if send == 0 {
                delegatelocation?.passLocation(array)
                delegatelocation?.locationRefresh()
            }
            dismiss(animated:true , completion: nil)
        } else {
            print("Incomplete form")
        }
    }
}

//Userdefault laundry stores name, name, name, index in string, index in string, index in string for location, accommodation and laundrette
