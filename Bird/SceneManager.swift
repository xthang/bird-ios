//
//  Created by Thang Nguyen on 10/19/21.
//

import SpriteKit

class SceneManager {
	
	private static let TAG = "ScM"
	
	enum SceneIdentifier {
		case home, end
		case game
	}
	
	static func prepareScene(_ id: SceneIdentifier) {
		switch id {
			case .home:
				_ = SKScene(fileNamed: "HomeScene")
			case .end:
				_ = SKScene(fileNamed: "EndScene")
			case .game:
				_ = SKScene(fileNamed: "GameScene")
		}
	}
}
