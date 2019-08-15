import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import TwitterKit

class LoginVC: UIViewController {

    @IBOutlet weak var emailTextField: InsetTextField!
    @IBOutlet weak var passwordTextField: InsetTextField!
    var handler: AuthStateDidChangeListenerHandle?
    let loginManager = LoginManager()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.uiDelegate = self
        isLoggedIn()
    }
    
    private func isLoggedIn(){
        handler = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if user != nil {
                AuthService.instace.createNewUserWithSoical(user: user!, completion: { (success) in
                    if success {
                        self.prepareToMainVC()
                    }
                })
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
    
    private func firebaseLogin(_ credential:AuthCredential){
        Auth.auth().signIn(with: credential) { (result, error) in
            if let error = error {
                debugPrint("firebaseLogin \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func googleSignIn(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @IBAction func facebookSignIn(_ sender: Any) {
        loginManager.logIn(permissions: ["email"], from: self) { (result, error) in
            if let error = error{
                debugPrint("facebookSignIn \(error.localizedDescription)")
            }else if result!.isCancelled{
                debugPrint("isCancelled")
            }else{
                let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
                self.firebaseLogin(credential)
            }
        }
    }
    
    @IBAction func twitterSignIn(_ sender: Any) {
        TWTRTwitter.sharedInstance().logIn { (session, error) in
            if let error = error{
                debugPrint("twitterSignIn \(error.localizedDescription)")
            }
            if let session = session{
                let credential = TwitterAuthProvider.credential(withToken: session.authToken, secret: session.authTokenSecret)
                self.firebaseLogin(credential)
            }
        }
    }
}

extension LoginVC: GIDSignInDelegate , GIDSignInUIDelegate{
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            debugPrint("error in GIDSignIn \(error.localizedDescription)")
        }else{
            guard let authentication = user.authentication else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
            firebaseLogin(credential)
        }
    }
}
