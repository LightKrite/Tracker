import Foundation
import YandexMobileMetrica

enum AnalyticsScreens: String {
    case main = "Main"
    case onboarding = "Onboaring"
    case statistics = "Statistics"
    case filters = "Filters"
    case type = "Type"
    case card = "Card"
    case edit = "Edit"
    case category = "Category"
    case categoryName = "CategoryName"
    case schedule = "Schedule"
}

enum AnalyticsItems: String {
    case add = "add_track"
    case track = "track"
    case filter = "filter"
    case edit = "edit"
    case delete = "delete"
}

struct AnalyticsService {
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "739da9f6-53eb-4cd0-9bfc-c07271adddb2") else { return }
        YMMYandexMetrica.activate(with: configuration)
    }
    
    func report(event: String, params : [AnyHashable : Any]) {
        YMMYandexMetrica.reportEvent(event, parameters: params, onFailure: { error in
            //print("REPORT ERROR: %@", error.localizedDescription)
        })
        //print("Success send \(event), \(params)")
    }
    
    func viewWillAppear(on screen: String) {
        report(event: "open", params: ["screen": screen])
    }
        
    func viewWillDisappear(from screen: String) {
        report(event: "close", params: ["screen": screen])
    }
    
    func didTap(_ item: String, _ screen: String) {
        report(event: "click", params: ["screen": screen, "item": item])
    }
}
