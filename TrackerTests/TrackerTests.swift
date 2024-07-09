import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    func testMainViewController() {
        let vc = TrackersListViewController()
        
        assertSnapshots(matching: vc, as: [.image(traits: UITraitCollection(userInterfaceStyle: .light))])
    }
    
    func testMainViewControllerDark() {
        let vc = TrackersListViewController()
        
        assertSnapshots(matching: vc, as: [.image(traits: UITraitCollection(userInterfaceStyle: .dark))])
    }
    
}

