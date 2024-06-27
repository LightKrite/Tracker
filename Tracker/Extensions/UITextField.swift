import UIKit

class TextFieldWithPadding: UITextField {
    
    var textPadding = UIEdgeInsets(
        top: 10,
        left: 16,
        bottom: 10,
        right: 16
    )
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        addTarget(self, action: #selector(setMaxLenght), for: .editingChanged)
    }
    
    @objc
    private func setMaxLenght() { text = String(text!.prefix(38)) }
}
