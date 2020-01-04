import UIKit
import MessageUI

class FeedbackSupportTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            sendEmail(isFeedback: true)
        } else if indexPath.row == 1 {
            sendEmail(isFeedback: false)
        }
    }
    
    func sendEmail(isFeedback feedback: Bool) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["unofficialfeedback77@gmail.com"])
            if !feedback {
                let file = ManageFile()
                if let json = file.readFromFile() {
                mail.setSubject("Json Data")
                mail.addAttachmentData(try! json.rawData(), mimeType: "application/json", fileName: "machine.json")
                    self.present(mail, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Warning", message: "No Scanned QR Code found", preferredStyle: .alert)
                    let dismiss = UIAlertAction(title: "dismiss", style: .cancel, handler: nil)
                    alert.addAction(dismiss)
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                self.present(mail, animated: true)
            }
        } else {
            print("Cannot send mail")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
