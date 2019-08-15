import UIKit
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //Firebase
        FirebaseApp.configure()
        //Google
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        //Facebook
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        //Twitter
        let key = Bundle.main.object(forInfoDictionaryKey: "consumerKey")
        let secret = Bundle.main.object(forInfoDictionaryKey: "consumerSecret")
        if let key = key as? String , let secret = secret as? String{
            TWTRTwitter.sharedInstance().start(withConsumerKey: key, consumerSecret: secret)
        }
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let returnGoogle = GIDSignIn.sharedInstance()?.handle(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        let returnFacebook = ApplicationDelegate.shared.application(app, open: url, options: options)
        let returnTwitter = TWTRTwitter.sharedInstance().application(app, open: url, options: options)
        return returnGoogle! || returnFacebook || returnTwitter
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
}
