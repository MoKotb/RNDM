import UIKit

class MainVC: UIViewController {

    @IBOutlet weak var categorySegmentedControl: UISegmentedControl!
    @IBOutlet weak var thoughtTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView(){
        thoughtTable.delegate = self
        thoughtTable.dataSource = self
    }
    
    @IBAction func onCategoryChanged(_ sender: Any) {
        
    }
    
    @IBAction func addNewThought(_ sender: Any) {
        
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        
    }
}

extension MainVC: UITableViewDelegate , UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: THOUGHT_CELL, for: indexPath) as? ThoughtCell {
            return cell
        }else{
            return ThoughtCell()
        }
    }
}
