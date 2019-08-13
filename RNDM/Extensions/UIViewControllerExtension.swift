import UIKit

extension UIViewController {
    
    func presentDetails(_ viewControllerToPresent:UIViewController){
        let transtion = CATransition()
        transtion.duration = 0.3
        transtion.type = .push
        transtion.subtype = .fromRight
        self.view.window?.layer.add(transtion,forKey: kCATransition)
        present(viewControllerToPresent, animated: false, completion: nil)
    }
    
    func dismissDetails(){
        let transtion = CATransition()
        transtion.duration = 0.3
        transtion.type = .push
        transtion.subtype = .fromLeft
        self.view.window?.layer.add(transtion,forKey: kCATransition)
        dismiss(animated: true, completion: nil)
    }
}
