//
//  Created by Thang Nguyen on 12/7/21.
//

import UIKit
import XLibrary

class SuccessScene: SceneOverlay {
	
	private let TAG = "\(SuccessScene.self)"
	
   private var gameNo: Int!
   
	func update(_ tag: String, levelScene: GameScene) {
		self.gameNo = levelScene.gameNo
		
	}
   
	override func popupDidShow(_ tag: String) {
		super.popupDidShow(tag)
		
		_ = (viewController as! GameViewController).showAdInterstitial("\(TAG)|popupDidShow|\(tag)", gameNo: gameNo)
	}
}
