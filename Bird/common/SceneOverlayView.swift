//
//  Created by Thang Nguyen on 10/15/21.
//

import UIKit

import XLibrary

class SceneOverlayView: OverlayView {
	
	private let TAG = "🪟"
	
	enum Identifier {
		case home
	}
	
	var id: Identifier!
	
	@IBOutlet public var playBtn: SceneButton?
	
	class func initiate(_ id: Identifier) -> SceneOverlayView {
		let overlay: SceneOverlayView
		switch id {
			case .home:
				overlay = initiate(fileName: "HomeScene") as! SceneOverlayView
		}
		overlay.id = id
		
		return overlay
	}
}
