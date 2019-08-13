import UIKit
import Firebase

protocol ThoughtDelegate {
    func thoughtOptionTapped(thought:Thought)
}

class ThoughtCell: UITableViewCell {

    @IBOutlet weak var userNameText: UILabel!
    @IBOutlet weak var timeText: UILabel!
    @IBOutlet weak var messageContentText: UILabel!
    @IBOutlet weak var likesText: UILabel!
    @IBOutlet weak var commentsText: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var optionImage: UIImageView!
    
    var thought:Thought!
    var delegate:ThoughtDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureLikes()
    }
    
    private func configureLikes(){
        let likeTab = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        likeImage.addGestureRecognizer(likeTab)
        likeImage.isUserInteractionEnabled = true
    }
    
    @objc private func likeTapped(){
        DataService.instace.updateThoughtLike(thought: thought) { (success, error) in
            if !success {
                debugPrint("ThoughtCell.likeTapped() \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    private func optionPressed(){
        let optionTap = UITapGestureRecognizer(target: self, action: #selector(optionTapped))
        optionImage.addGestureRecognizer(optionTap)
        optionImage.isUserInteractionEnabled = true
    }
    
    @objc private func optionTapped(){
        delegate?.thoughtOptionTapped(thought: thought)
    }
    
    func configureCell(thought:Thought,userName:String,delegate:ThoughtDelegate){
        self.delegate = delegate
        self.thought = thought
        userNameText.text = userName 
        timeText.text = configureTime(time: thought.thoughtTime)
        messageContentText.text = thought.thoughtContent
        likesText.text = String(thought.thoughtLikes)
        commentsText.text = String(thought.thoughtComments)
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
        if thought.thoughtUserId == Auth.auth().currentUser?.uid{
            optionImage.isHidden = false
            optionPressed()
        }else{
            optionImage.isHidden = true
        }
    }
}
