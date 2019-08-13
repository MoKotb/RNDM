import UIKit

@IBDesignable
class InsetTextField: UITextField {

    @IBInspectable var placeholderColor:UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) {
        didSet{
            self.setNeedsLayout()
        }
    }
    var padding:UIEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    
    private func setupView(){
        if let placeholderText = placeholder{
            let place = NSAttributedString(string: placeholderText, attributes: [NSAttributedString.Key.foregroundColor : placeholderColor])
            attributedPlaceholder = place
        }
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
