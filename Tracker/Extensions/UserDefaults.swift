import Foundation

extension UserDefaults {
    private enum UserDefaultsKeys: String {
        case isNotFirstRun
    }
    
    var isNotFirstRun: Bool {
        get {
            bool(forKey: UserDefaultsKeys.isNotFirstRun.rawValue)
        }
        set {
            setValue(newValue, forKey: UserDefaultsKeys.isNotFirstRun.rawValue)
        }
    }
}
