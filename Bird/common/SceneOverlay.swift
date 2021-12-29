//
//  Created by Thang Nguyen on 10/15/21.
//

import UIKit

import XLibrary

class SceneOverlay: OverlayView {
	
	private let TAG = "🪟"
	
	enum Identifier {
		case home, end, success, fail, pause
	}
	
	var id: Identifier!
	
	@IBOutlet public var playBtn: SceneButton?
	
	class func initiate(_ id: Identifier) -> SceneOverlay {
		let overlay: SceneOverlay
		switch id {
			case .home:
				overlay = initiate(fileName: "HomeScene") as! SceneOverlay
			case .end:
				overlay = initiate(fileName: "EndScene") as! SceneOverlay
			case .pause:
				overlay = initiate(fileName: "PauseScene") as! SceneOverlay
			case .success:
				overlay = initiate(fileName: "SuccessScene") as! SceneOverlay
			case .fail:
				overlay = initiate(fileName: "FailScene") as! SceneOverlay
		}
		overlay.id = id
		
		return overlay
	}
}
