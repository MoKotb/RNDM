import Foundation
import Firebase

class DataService {
    
    static let instace = DataService()
    
    public private(set) var REF_BASE = DB_BASE
    public private(set) var REF_USERS = DB_BASE.collection("users")
    public private(set) var REF_THOUGHT = DB_BASE.collection("thoughts")
    var thoughtListner:ListenerRegistration!
    var commentListner:ListenerRegistration!
    
    func createNewUser(userID:String,userData:Dictionary<String,Any>,completion:@escaping (_ status:Bool,_ error:Error?)->()){
        REF_USERS.document(userID).setData(userData) { (error) in
            if error == nil{
                completion(true,nil)
            }else{
                debugPrint("DataService.createNewUser() \(String(describing: error?.localizedDescription))")
                completion(false,error)
            }
        }
    }
    
    func getUserNameById(userID:String,completion:@escaping (_ userName:String?)->()){
        REF_USERS.getDocuments { (snapShot, error) in
            if error != nil {
                completion(nil)
            }else{
                guard let snap = snapShot else { return }
                for docment in snap.documents{
                    let data = docment.data()
                    let userId = docment.documentID
                    if userID == userId{
                        let username = data["username"] as? String ?? ""
                        completion(username)
                    }
                }
                completion(nil)
            }
        }
    }
    
    func createNewThought(thoughtData:Dictionary<String,Any>,completion:@escaping (_ status:Bool,_ error:Error?)->()){
        REF_THOUGHT.addDocument(data: thoughtData) { (error) in
            if error == nil{
                completion(true,nil)
            }else{
                debugPrint("DataService.createNewThought() \(String(describing: error?.localizedDescription))")
                completion(false,error)
            }
        }
    }
    
    func getAllThoughts(category:String,completion:@escaping (_ thoughtList:[Thought]?,_ error:Error?)->()){
        var thoughtList = [Thought]()
        let thought = Thought()
        if category == CategoryType.Popular.rawValue {
            thoughtListner = REF_THOUGHT.order(by: "numOfLikes", descending: true).addSnapshotListener { (snapshot, error) in
                if error != nil {
                    completion(nil,error)
                }else{
                    thoughtList = thought.parseThoughtData(snapshot: snapshot)
                    completion(thoughtList,nil)
                }
            }
        }else{
            thoughtListner = REF_THOUGHT.whereField("category", isEqualTo: category).order(by: "timestamp", descending: true).addSnapshotListener { (snapshot, error) in
                if error != nil {
                    completion(nil,error)
                }else{
                    thoughtList = thought.parseThoughtData(snapshot: snapshot)
                    completion(thoughtList,nil)
                }
            }
        }
    }
    
    func removeThoughtListner(){
        thoughtListner.remove()
    }
    
    func updateThoughtLike(thought:Thought,completion:@escaping (_ status:Bool,_ error:Error?)->()){
        REF_THOUGHT.document(thought.thoughtId).updateData(["numOfLikes": thought.thoughtLikes + 1]) { (error) in
            if error != nil {
                completion(false,error)
            }else{
                completion(true,nil)
            }
        }
    }
    
    func addNewComment(thought:Thought,commentContent:String,completion:@escaping (_ status:Bool)->()){
        REF_BASE.runTransaction({ (transaction, errorPointer) -> Any? in
            let thoughtDocument:DocumentSnapshot
            do{
                try thoughtDocument = transaction.getDocument(self.REF_THOUGHT.document(thought.thoughtId))
            }catch {
                return nil
            }
            guard let oldCommentsNumber = thoughtDocument.data()?["numOfComments"] as? Int else { return nil }
            transaction.updateData(["numOfComments":oldCommentsNumber + 1], forDocument: self.REF_THOUGHT.document(thought.thoughtId))
            let REF_COMMENT = self.REF_THOUGHT.document(thought.thoughtId).collection("comments").document()
            let userId = Auth.auth().currentUser?.uid
            let commentData:[String:Any] = ["comment":commentContent,"timestamp":FieldValue.serverTimestamp(),"userId":userId ?? ""]
            transaction.setData(commentData, forDocument: REF_COMMENT)
            return nil
        }) { (object, error) in
            if error != nil{
                debugPrint("DataService.addNewComment() \(String(describing: error?.localizedDescription))")
                completion(false)
            }else{
                completion(true)
            }
        }
    }
    
    func getAllComments(thoughtId:String,completion:@escaping (_ commentList:[Comment]?,_ error:Error?)->()){
        var commentList = [Comment]()
        let comment = Comment()
        commentListner = REF_THOUGHT.document(thoughtId).collection("comments").order(by: "timestamp", descending: false).addSnapshotListener { (snapshot, error) in
            if error != nil {
                completion(nil,error)
            }else{
                commentList = comment.parseCommentData(snapshot: snapshot)
                completion(commentList,nil)
            }
        }
    }
    
    func removeCommentListner(){
        commentListner.remove()
    }
    
    func deleteComment(thoughtId:String,commentId:String,completion:@escaping (_ status:Bool)->()){
        REF_BASE.runTransaction({ (transaction, errorPointer) -> Any? in
            let thoughtDocument:DocumentSnapshot
            do{
                try thoughtDocument = transaction.getDocument(self.REF_THOUGHT.document(thoughtId))
            }catch {
                return nil
            }
            guard let oldCommentsNumber = thoughtDocument.data()?["numOfComments"] as? Int else { return nil }
            transaction.updateData(["numOfComments":oldCommentsNumber - 1], forDocument: self.REF_THOUGHT.document(thoughtId))
            let commentRef = self.REF_THOUGHT.document(thoughtId).collection("comments").document(commentId)
            transaction.deleteDocument(commentRef)
            return nil
        }) { (object, error) in
            if error != nil{
                debugPrint("DataService.deleteComment() \(String(describing: error?.localizedDescription))")
                completion(false)
            }else{
                completion(true)
            }
        }
    }
    
    func updateComment(thoughtId:String,commentId:String,commentText:String,completion:@escaping (_ status:Bool)->()){
        REF_THOUGHT.document(thoughtId).collection("comments").document(commentId).updateData(["comment":commentText]) { (error) in
            if error == nil{
                completion(true)
            }else{
                completion(false)
            }
        }
    }
    
    func deleteThought(thoughtId:String,completion:@escaping (_ status:Bool)->()){
        REF_THOUGHT.document(thoughtId).delete { (error) in
            if error == nil{
                completion(true)
            }else{
                completion(false)
            }
        }
    }
    
    func deleteSubCollection(thoughtId:String,batchSize:Int = 100,completion:@escaping (Error?)->()){
        let collection = REF_THOUGHT.document(thoughtId).collection("comments")
        collection.limit(to: batchSize).getDocuments { (docset, error) in
            guard let docset = docset else {
                completion(error)
                return
            }
            guard docset.count > 0 else {
                completion(nil)
                return
            }
            let batch = collection.firestore.batch()
            docset.documents.forEach{batch.deleteDocument($0.reference)}
            batch.commit(completion: { (batchError) in
                if let batchError = batchError {
                    completion(batchError)
                }else{
                    self.deleteSubCollection(thoughtId: thoughtId, batchSize: batchSize, completion: completion)
                }
            })
        }
    }
}
