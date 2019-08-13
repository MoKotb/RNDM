import UIKit

class MainVC: UIViewController {

    @IBOutlet weak var categorySegmentedControl: UISegmentedControl!
    @IBOutlet weak var thoughtTable: UITableView!
    
    var thoughtList = [Thought]()
    var selectedCategory:CategoryType = .Funny
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView(){
        thoughtTable.delegate = self
        thoughtTable.dataSource = self
        thoughtTable.estimatedRowHeight = 100
        thoughtTable.rowHeight = UITableView.automaticDimension
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        downloadThought()
    }
    
    private func downloadThought(){
        DataService.instace.getAllThoughts(category: selectedCategory.rawValue) { (thoughts, error) in
            if error != nil {
                debugPrint("MainVC.downloadThought() \(String(describing: error?.localizedDescription))")
            }else{
                self.thoughtList = []
                guard let newThoughts = thoughts else { return }
                self.thoughtList = newThoughts
                self.thoughtTable.reloadData()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        DataService.instace.removeThoughtListner()
    }
    
    @IBAction func onCategoryChanged(_ sender: Any) {
        switch categorySegmentedControl.selectedSegmentIndex {
        case 0:
            selectedCategory = CategoryType.Funny
        case 1:
            selectedCategory = CategoryType.Serious
        case 2:
            selectedCategory = CategoryType.Crazy
        case 3:
            selectedCategory = CategoryType.Popular
        default:
            selectedCategory = CategoryType.Funny
        }
        DataService.instace.removeThoughtListner()
        downloadThought()
    }
    
    @IBAction func addNewThought(_ sender: Any) {
        guard let addThoughtVC = storyboard?.instantiateViewController(withIdentifier: ADD_THOUGHT_VC_IDENTIFIER) as? AddThoughtVC else { return }
        self.navigationController?.pushViewController(addThoughtVC, animated: true)
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        AuthService.instace.logoutUser { (success) in
            if success {
                self.prepareToLoginVC()
            }
        }
    }
    
    private func prepareToLoginVC(){
        dismissDetails()
    }
    
    private func showAlert(thought:Thought){
        let alert = UIAlertController(title: "Delete", message: "Do you want to delete your thought ?", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete Thought", style: .destructive) { (action) in
            DataService.instace.deleteSubCollection(thoughtId: thought.thoughtId, completion: { (error) in
                if error != nil {
                    debugPrint("Erorr in \(String(describing: error))")
                }else{
                    DataService.instace.deleteThought(thoughtId: thought.thoughtId, completion: { (success) in
                        if success {
                            alert.dismiss(animated: true, completion: nil)
                        }
                    })
                }
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}

extension MainVC: UITableViewDelegate , UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return thoughtList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: THOUGHT_CELL, for: indexPath) as? ThoughtCell {
            let thought = thoughtList[indexPath.row]
            DataService.instace.getUserNameById(userID: thought.thoughtUserId) { (name) in
                guard let username = name else { return }
                cell.configureCell(thought: thought, userName: username,delegate: self)
            }
            return cell
        }else{
            return ThoughtCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let thought = thoughtList[indexPath.row]
        guard let commentsVC = storyboard?.instantiateViewController(withIdentifier: COMMENTS_VC_IDENTIFIER) as? CommentsVC else { return }
        commentsVC.initData(thought: thought)
        self.navigationController?.pushViewController(commentsVC, animated: true)
    }
}

extension MainVC: ThoughtDelegate {
    func thoughtOptionTapped(thought:Thought) {
        showAlert(thought:thought)
    }
}
