import UIKit
import Firebase

class LoginVC: UIViewController {

    @IBOutlet weak var emailTextField: InsetTextField!
    @IBOutlet weak var passwordTextField: InsetTextField!
    var handler: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isLoggedIn()
    }
    
    private func isLoggedIn(){
        handler = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if user != nil {
                self.prepareToMainVC()
            }
        })
    }
    
    @IBAction func onLoginPressed(_ sender: Any) {
        guard let email = emailTextField.text , emailTextField.text != "" else { return }
        guard let password = passwordTextField.text , passwordTextField.text != "" else { return }
        userLogin(email: email, password: password)
    }
    
    private func userLogin(email:String,password:String){
        AuthService.instace.loginUser(email: email, password: password) { (success, error) in
            if success {
                self.emailTextField.text = ""
                self.passwordTextField.text = ""
                self.prepareToMainVC()
            }else{
                debugPrint("LoginVC.userLogin() \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    private func prepareToMainVC(){
        guard let mainVC = storyboard?.instantiateViewController(withIdentifier: TAB_IDENTIFIER) else { return }
        presentDetails(mainVC)
    }
    
    @IBAction func onCreateAccountPressed(_ sender: Any) {
        guard let createAccountVC = storyboard?.instantiateViewController(withIdentifier: CREATE_ACCOUNT_VC_IDENTIFIER) as? CreateAccountVC else { return }
        presentDetails(createAccountVC)
    }
}

