import Foundation

class Thought{
    
    public private(set) var thoughtId:String!
    public private(set) var thoughtTime:Data!
    public private(set) var thoughtContent:String!
    public private(set) var thoughtLikes:Int!
    public private(set) var thoughtComments:Int!
    public private(set) var thoughtUsername:String!
    
    init(thoughtId:String,thoughtTime:Data,thoughtContent:String,thoughtLikes:Int,thoughtComments:Int,thoughtUsername:String) {
        self.thoughtId = thoughtId
        self.thoughtTime = thoughtTime
        self.thoughtContent = thoughtContent
        self.thoughtLikes = thoughtLikes
        self.thoughtComments = thoughtComments
        self.thoughtUsername = thoughtUsername
    }
}
