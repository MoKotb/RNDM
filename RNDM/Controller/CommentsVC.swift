import UIKit

class CommentsVC: UIViewController {

    @IBOutlet weak var commentTextField: InsetTextField!
    @IBOutlet weak var commentTable: UITableView!
    
    var commentList = [Comment]()
    var thought:Thought!
    
    func initData(thought:Thought){
        self.thought = thought
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView(){
        commentTable.delegate = self
        commentTable.dataSource = self
        self.view.bindToKeyboard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        downloadComment()
    }
    
    private func downloadComment(){
        DataService.instace.getAllComments(thoughtId: thought.thoughtId) { (comments, error) in
            if error != nil {
                debugPrint("CommentsVC.downloadComment() \(String(describing: error?.localizedDescription))")
            }else{
                self.commentList = []
                guard let newComments = comments else { return }
                self.commentList = newComments
                self.commentTable.reloadData()
            }
        }
    }
    
    @IBAction func addNewComment(_ sender: Any) {
        guard let comment = commentTextField.text , commentTextField.text != "" else { return }
        DataService.instace.addNewComment(thought: thought, commentContent: comment) { (success) in
            if success {
                self.commentTextField.text = ""
                self.commentTextField.resignFirstResponder()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        DataService.instace.removeCommentListner()
    }
    
    private func showAlert(comment: Comment){
        let alert = UIAlertController(title: "Edit Comment", message: "You can edit or delete !", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            DataService.instace.deleteComment(thoughtId: self.thought.thoughtId, commentId: comment.commentId, completion: { (success) in
                if success{
                    alert.dismiss(animated: true, completion: nil)
                }
            })
        }
        let editAction = UIAlertAction(title: "Edit", style: .destructive) { (action) in
            self.showUpdateComment(comment: comment)
            alert.dismiss(animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(editAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func showUpdateComment(comment: Comment){
        guard let updateCommentVC = storyboard?.instantiateViewController(withIdentifier: UPDATE_COMMENTS_VC_IDENTIFIER) as? UpdateCommentVC else { return }
        updateCommentVC.initData(thought: thought, comment: comment)
        self.navigationController?.pushViewController(updateCommentVC, animated: true)
    }
    
}

extension CommentsVC: UITableViewDelegate , UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: COMMENT_CELL, for: indexPath) as? CommentCell {
            let comment = commentList[indexPath.row]
            DataService.instace.getUserNameById(userID: comment.commentUserId) { (username) in
                guard let name = username else { return }
                cell.configureCell(comment: comment,userName: name,delegate: self)
            }
            return cell
        }else{
            return CommentCell()
        }
    }
}

extension CommentsVC: CommentDelegate {
    func commentOptionTapped(comment: Comment) {
        showAlert(comment:comment)
    }
}
