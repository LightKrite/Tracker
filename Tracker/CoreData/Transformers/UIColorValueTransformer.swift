import UIKit

@objc
final class UIColorValueTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        return UIColor.self
    }
    override class func allowsReverseTransformation() -> Bool {
        true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let color = value as? UIColor else { return nil}
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: true)
            return data
        } catch {
            assertionFailure("Failed to transform 'UIColor' to 'Data'")
            return nil
        }
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        do {
            let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data as Data)
            return color
        } catch {
            assertionFailure("Failed to transform 'Data' to 'UIColor'")
            return nil
        }
    }
    
    static func register() {
        ValueTransformer.setValueTransformer(
            UIColorValueTransformer(),
            forName: NSValueTransformerName(rawValue: String(describing: UIColorValueTransformer.self)))
    }
}
