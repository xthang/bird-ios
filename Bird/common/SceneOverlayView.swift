//
//  Created by Thang Nguyen on 10/15/21.
//

import UIKit

import XLibrary

class SceneOverlayView: OverlayView {
	
	private let TAG = "🪟"
	
	enum Identifier {
		case home, end, success, fail, pause
	}
	
	var id: Identifier!
	
	@IBOutlet public var playBtn: SceneButton?
	
	class func initiate(_ id: Identifier) -> SceneOverlayView {
		let overlay: SceneOverlayView
		switch id {
			case .home:
				overlay = initiate(fileName: "HomeScene") as! SceneOverlayView
			case .end:
				overlay = initiate(fileName: "EndScene") as! SceneOverlayView
			case .pause:
				overlay = initiate(fileName: "PauseScene") as! SceneOverlayView
			case .success:
				overlay = initiate(fileName: "SuccessScene") as! SceneOverlayView
			case .fail:
				overlay = initiate(fileName: "FailScene") as! SceneOverlayView
		}
		overlay.id = id
		
		return overlay
	}
}
