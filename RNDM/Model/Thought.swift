import Foundation
import Firebase

class Thought{
    
    public private(set) var thoughtId:String!
    public private(set) var thoughtTime:Date!
    public private(set) var thoughtContent:String!
    public private(set) var thoughtLikes:Int!
    public private(set) var thoughtComments:Int!
    public private(set) var thoughtUserId:String!
    
    init(){}
    
    init(thoughtId:String,thoughtTime:Date,thoughtContent:String,thoughtLikes:Int,thoughtComments:Int,thoughtUserId:String) {
        self.thoughtId = thoughtId
        self.thoughtTime = thoughtTime
        self.thoughtContent = thoughtContent
        self.thoughtLikes = thoughtLikes
        self.thoughtComments = thoughtComments
        self.thoughtUserId = thoughtUserId
    }
    
    func parseThoughtData(snapshot:QuerySnapshot?) -> [Thought]{
        var thoughtList = [Thought]()
        guard let snap = snapshot else { return thoughtList }
        for document in snap.documents {
            let data = document.data()
            let thoughtId = document.documentID
            let thoughtTime = data["timestamp"] as! Timestamp
            let thoughtContent = data["message"] as! String
            let thoughtLikes = data["numOfLikes"] as! Int
            let thoughtComments = data["numOfComments"] as! Int
            let thoughtUserId = data["userId"] as! String
            let thought = Thought(thoughtId: thoughtId, thoughtTime: thoughtTime.dateValue(), thoughtContent: thoughtContent, thoughtLikes: thoughtLikes, thoughtComments: thoughtComments, thoughtUserId: thoughtUserId)
            thoughtList.append(thought)
        }
        return thoughtList
    }
}
