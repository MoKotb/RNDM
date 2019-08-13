import UIKit
import Firebase

class AddThoughtVC: UIViewController {

    @IBOutlet weak var categorySegmentedControl: UISegmentedControl!
    @IBOutlet weak var messageContentText: InsetTextView!
    
    var selectedCategory:CategoryType = .Funny
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView(){
        messageContentText.delegate = self
    }
    
    @IBAction func categoryChanged(_ sender: Any) {
        switch categorySegmentedControl.selectedSegmentIndex {
        case 0:
            selectedCategory = CategoryType.Funny
        case 1:
            selectedCategory = CategoryType.Serious
        case 2:
            selectedCategory = CategoryType.Crazy
        default:
            selectedCategory = CategoryType.Funny
        }
    }
    
    @IBAction func onPostPressed(_ sender: Any) {
        guard let message = messageContentText.text , messageContentText.text != "" , messageContentText.text != "My random thought..." else { return }
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let thoughtData:[String:Any] = ["message":message,"timestamp":FieldValue.serverTimestamp(),"userId":userId,"category":selectedCategory.rawValue,"numOfLikes":0,"numOfComments":0]
        sendThoughtData(thoughtData: thoughtData)
    }
    
    private func sendThoughtData(thoughtData:Dictionary<String,Any>){
        DataService.instace.createNewThought(thoughtData: thoughtData) { (success, error) in
            if success {
                self.navigationController?.popViewController(animated: true)
            }else{
                debugPrint("AddThoughtVC.sendThoughtData() \(String(describing: error?.localizedDescription))")
            }
        }
    }
}

extension AddThoughtVC: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        messageContentText.text = ""
        messageContentText.textColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if messageContentText.text == ""{
            messageContentText.text = "My random thought..."
            messageContentText.textColor = #colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 1)
        }
    }
}
