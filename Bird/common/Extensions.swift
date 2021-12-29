//
//  Created by Thang Nguyen on 10/19/21.
//

import XLibrary
import UIKit

extension UIColor {
	
	static let logo1 = UIColor.rgb(0x0392CF)
}

extension Snackbar {
	
	public static func warn(_ msg: String) {
		DispatchQueue.main.async {
			let snackbar = initSnackbar(msg, duration: .short)
			
			snackbar.centerYMultiplier = 1
			snackbar.backgroundColor = .rgb(0, alpha: 0.6)
			snackbar.messageTextFont = .init(name: CommonConfig.fontName, size: snackbar.messageTextFont.pointSize)!
			snackbar.messageTextColor = .white
			
			snackbar.animationType = .fadeInFadeOut
			snackbar.show()
		}
	}
}
