/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A state used by `LevelScene` to provide appropriate UI via an overlay scene when the game is paused.
 */

import SpriteKit
import GameplayKit

class LevelScenePauseState: LevelSceneOverlayState {
	// MARK: Properties
	
	override var overlaySceneFileName: String {
		return "PauseScene"
	}
	
	// MARK: GKState Life Cycle
	
	override func didEnter(from previousState: GKState?) {
		super.didEnter(from: previousState)
		
		if levelScene.gameState == .STARTED {
			levelScene.gameState = .PAUSED
		}
		
		levelScene.speed = 0
		levelScene.physicsWorld.speed = 0
		
		// levelScene.save("LevelScenePauseState|didEnter")
	}
	
	override func isValidNextState(_ stateClass: AnyClass) -> Bool {
		return stateClass is LevelSceneActiveState.Type
	}
	
	override func willExit(to nextState: GKState) {
		super.willExit(to: nextState)
		
		// levelScene.worldNode.isPaused = false
	}
}
