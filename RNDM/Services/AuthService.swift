import Foundation
import Firebase

class AuthService {
    
    static let instace = AuthService()
    
    func createNewUser(username:String,email:String,password:String,completion:@escaping (_ status:Bool,_ error:Error?)->()){
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            guard let newUser = result?.user else {
                completion(false,error)
                return
            }
            let changeRequest = newUser.createProfileChangeRequest()
            changeRequest.displayName = username
            changeRequest.commitChanges(completion: { (error) in
                if let err = error {
                    completion(false,err)
                }
            })
            let userData:[String:Any] = ["provider":newUser.providerID,"email":email,"username":username,"timestamp":FieldValue.serverTimestamp()]
            DataService.instace.createNewUser(userID: newUser.uid, userData: userData, completion: { (success, error) in
                if success {
                    completion(true,nil)
                }else{
                    completion(false,error)
                }
            })
        }
    }
    
    func loginUser(email:String,password:String,completion:@escaping (_ status:Bool,_ error:Error?)->()){
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error{
                completion(false,error)
            }else{
                completion(true,nil)
            }
        }
    }
    
    func logoutUser(completion:@escaping (_ status:Bool)->()) {
        do{
            try Auth.auth().signOut()
            completion(true)
        }catch{
            completion(false)
        }
    }
}
