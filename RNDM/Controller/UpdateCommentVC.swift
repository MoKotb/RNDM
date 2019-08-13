import UIKit

class UpdateCommentVC: UIViewController {

    @IBOutlet weak var messageContentTextView: InsetTextView!
    
    var thought:Thought!
    var comment:Comment!
    
    func initData(thought:Thought,comment:Comment){
        self.thought = thought
        self.comment = comment
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView(){
        messageContentTextView.text = comment.commentContent
    }
    
    @IBAction func updateComment(_ sender: Any) {
        guard let message = messageContentTextView.text , messageContentTextView.text != "" , messageContentTextView.text != "My random thought..." else { return }
        DataService.instace.updateComment(thoughtId: thought.thoughtId, commentId: comment.commentId, commentText: message) { (success) in
            if success {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
