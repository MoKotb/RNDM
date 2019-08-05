import UIKit

@IBDesignable
class InsetTextView: UITextView {

    @IBInspectable var cornerRadius : CGFloat = 5.0{
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }
    var padding:UIEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    
    private func setupView(){
        self.contentInset = padding
        self.layer.cornerRadius = cornerRadius
    }
}
