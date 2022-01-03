//
//  Created by Thang Nguyen on 1/3/22.
//

import SpriteKit

import XLibrary

class GamePauseScene: SceneOverlay {
	
	private let TAG = "\(GamePauseScene.self)"
	
	private lazy var buttons = childNode(withName: "Buttons")!
	private lazy var btnResume = buttons.childNode(withName: "Resume") as! ButtonNode
	
	
	override func sceneDidLoad(_ tag: String) {
		super.sceneDidLoad(tag)
		
		[btnResume].forEach {
			$0.imgNode!.texture!.filteringMode = .nearest
		}
	}
	
	override func willMove(_ tag: String, to scene: SKScene) {
		super.willMove(tag, to: scene)
		
		[btnResume].forEach {
			let btnTextureSize = $0.imgNode!.texture!.size()
			let scale = min(scene.frame.height * 0.05 / btnTextureSize.height, scene.frame.width * 0.1 / btnTextureSize.width)
			$0.imgNode!.size = CGSize(width: btnTextureSize.width * scale, height: btnTextureSize.height * scale)
			$0.size = CGSize(width: $0.imgNode!.size.width + 6, height: $0.imgNode!.size.height + 6)
		}
		
		alpha = 0
		run(SKAction.fadeIn(withDuration: 0.25))
	}
}
