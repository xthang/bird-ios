/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A state used by `LevelScene` to indicate that the player failed to complete a level.
 */

import SpriteKit
import GameplayKit

class LevelSceneFinishState: LevelSceneOverlayState {
	// MARK: Properties
	
	override var overlaySceneFileName: String {
		return "GameFinishScene"
	}
	
	// MARK: GKState Life Cycle
	
	override func didEnter(from previousState: GKState?) {
		(overlay as! GameFinishScene).update("didEnter", levelScene: levelScene)
		
		super.didEnter(from: previousState)
	}
	
	override func isValidNextState(_ stateClass: AnyClass) -> Bool {
		return stateClass is LevelSceneActiveState.Type
	}
}
