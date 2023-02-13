

import Foundation
import CommonCrypto

class AccountUtil: NSObject {
    
    static let shared = AccountUtil.init()
    
    static let WS_SERVER : String = "192.168.0.4:8800"

    
    override init() {
        SVProgressHUD.setMinimumDismissTimeInterval(3.0)
        SVProgressHUD.setMaximumDismissTimeInterval(30.0)
    }
    
}
