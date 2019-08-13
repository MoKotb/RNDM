import Foundation
import Firebase

class Comment {
    public private(set) var commentId:String!
    public private(set) var commentTime:Date!
    public private(set) var commentContent:String!
    public private(set) var commentUserId:String!
    
    init(){}
    
    init(commentId:String,commentTime:Date,commentContent:String,commentUserId:String) {
        self.commentId = commentId
        self.commentTime = commentTime
        self.commentContent = commentContent
        self.commentUserId = commentUserId
    }
    
    func parseCommentData(snapshot:QuerySnapshot?) -> [Comment]{
        var commentList = [Comment]()
        guard let snap = snapshot else { return commentList }
        for document in snap.documents {
            let data = document.data()
            let commentId = document.documentID
            let commentTime = data["timestamp"] as! Timestamp
            let commentContent = data["comment"] as! String
            let commentUserId = data["userId"] as! String
            let comment = Comment(commentId: commentId, commentTime: commentTime.dateValue(), commentContent: commentContent, commentUserId: commentUserId)
            commentList.append(comment)
        }
        return commentList
    }
}
