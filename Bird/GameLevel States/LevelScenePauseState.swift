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
		return "GamePauseScene"
	}
	
	// MARK: GKState Life Cycle
	
	override func didEnter(from previousState: GKState?) {
		super.didEnter(from: previousState)
		
		if levelScene.gameState == .STARTED {
			levelScene.gameState = .PAUSED
		}
		
		// levelScene.save("LevelScenePauseState|didEnter")
	}
	
	override func isValidNextState(_ stateClass: AnyClass) -> Bool {
		return !(stateClass is LevelScenePauseState.Type)
	}
}
