
import UIKit

@objc public class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Application delegate 完成加载
    
    @objc public var window: UIWindow?
    
    @objc public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window?.tintColor = .black
        return true
    }
 
}


