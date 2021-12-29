//
//  Created by Thang Nguyen on 12/28/21.
//

import SpriteKit
import GameplayKit

import XLibrary

class HomeScene: BaseScene {
	
	private let TAG = "🎲"
	
	/// Returns the background node from the scene.
	var backgroundNode: SKSpriteNode? {
		return childNode(withName: "backgroundNode") as? SKSpriteNode
	}
	
	/// The "NEW GAME" button which allows the player to proceed to the first level.
	var proceedButton: ButtonNode? {
		return backgroundNode?.childNode(withName: ButtonIdentifier.play.rawValue) as? ButtonNode
	}
	
	override func sceneDidLoad() {
		NSLog("--  \(TAG) | sceneDidLoad: \(hash)")
		
		if true {
			proceedButton?.labelNode?.text = "{PLAY}"
		}
		
		// SceneManager.prepareScene(.level)
	}
	
	override func didMove(to view: SKView) {
		// NSLog("--  \(TAG) | didMove to view | \(size)")
		super.didMove(to: view)
		
		let homeScene = SceneOverlay.initiate(.home)
		view.addSubview(homeScene)
	}
}
