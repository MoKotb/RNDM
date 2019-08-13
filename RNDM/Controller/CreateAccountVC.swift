import UIKit

class CreateAccountVC: UIViewController {

    @IBOutlet weak var userTextField: InsetTextField!
    @IBOutlet weak var emailTextField: InsetTextField!
    @IBOutlet weak var passwordTextField: InsetTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onCreateAccountPressed(_ sender: Any) {
        guard let username = userTextField.text , userTextField.text != "" else { return }
        guard let email = emailTextField.text , emailTextField.text != "" else { return }
        guard let password = passwordTextField.text , passwordTextField.text != "" else { return }
        createNewUser(username: username, email: email, password: password)
    }
    
    private func createNewUser(username: String, email: String, password: String){
        AuthService.instace.createNewUser(username: username, email: email, password: password) { (success, error) in
            if success {
                self.userTextField.text = ""
                self.emailTextField.text = ""
                self.passwordTextField.text = ""
                self.prepareToMainVC()
            }else{
                debugPrint("CreateAccountVC.onCreateAccountPressed() \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    private func prepareToMainVC(){
        guard let mainVC = storyboard?.instantiateViewController(withIdentifier: TAB_IDENTIFIER) else { return }
        presentDetails(mainVC)
    }
    
    @IBAction func onCancelPressed(_ sender: Any) {
        dismissDetails()
    }
}
