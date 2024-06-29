import UIKit

extension UILabel {

    /// spacingValue is spacing that you need
    func addInterlineSpacing(spacingValue: CGFloat = 2) {
        /// check if there's any text
        guard let textString = text else { return }
        /// create "NSMutableAttributedString" with your text
        let attributedString = NSMutableAttributedString(string: textString)
        /// create instance of "NSMutableParagraphStyle"
        let paragraphStyle = NSMutableParagraphStyle()
        /// actually adding spacing we need to ParagraphStyle
        paragraphStyle.lineSpacing = spacingValue
        /// adding ParagraphStyle to your attributed String
        attributedString.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: attributedString.length
        ))
        /// assign string that you've modified to current attributed Text
        attributedText = attributedString
    }

}
