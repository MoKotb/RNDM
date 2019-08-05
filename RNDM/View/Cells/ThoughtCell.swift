import UIKit

class ThoughtCell: UITableViewCell {

    @IBOutlet weak var userNameText: UILabel!
    @IBOutlet weak var timeText: UILabel!
    @IBOutlet weak var messageContentText: UILabel!
    @IBOutlet weak var likesText: UILabel!
    @IBOutlet weak var commentsText: UILabel!
    
    func configureCell(thought:Thought){
        
    }
}
