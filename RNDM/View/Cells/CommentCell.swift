import UIKit
import Firebase

protocol CommentDelegate {
    func commentOptionTapped(comment:Comment)
}

class CommentCell: UITableViewCell {

    @IBOutlet weak var usernameText: UILabel!
    @IBOutlet weak var dateText: UILabel!
    @IBOutlet weak var contentText: UILabel!
    @IBOutlet weak var optionImage: UIImageView!
    
    var delegate:CommentDelegate?
    var comment:Comment!
    
    func configureCell(comment:Comment,userName:String,delegate:CommentDelegate){
        self.delegate = delegate
        self.comment = comment
        usernameText.text = userName
        dateText.text = configureTime(time: comment.commentTime)
        contentText.text = comment.commentContent
        configureOption()
    }
    
    private func configureTime(time:Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d,hh:mm"
        let timestamp = formatter.string(from: time)
        return timestamp
    }
    
    private func configureOption(){
        optionImage.isHidden = true
        if comment.commentUserId == Auth.auth().currentUser?.uid{
            optionImage.isHidden = false
            optionPressed()
        }else{
            optionImage.isHidden = true
        }
    }
    
    private func optionPressed(){
        let optionTap = UITapGestureRecognizer(target: self, action: #selector(optionTapped))
        optionImage.addGestureRecognizer(optionTap)
        optionImage.isUserInteractionEnabled = true
    }
    
    @objc private func optionTapped(){
        delegate?.commentOptionTapped(comment: comment)
    }
}
