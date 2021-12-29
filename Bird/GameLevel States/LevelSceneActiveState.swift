/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A state used by `LevelScene` to indicate that the game is actively being played. This state updates the current time of the level's countdown timer.
 */

import SpriteKit
import GameplayKit

class LevelSceneActiveState: GKState {
	// MARK: Properties
	
	unowned let levelScene: GameScene
	
	var timePassed: TimeInterval = 0.0
	
	/*
	 A formatter for individual date components used to provide an appropriate
	 display value for the timer.
	 */
	let timeFormatter: DateComponentsFormatter = {
		let formatter = DateComponentsFormatter()
		formatter.zeroFormattingBehavior = .pad
		formatter.allowedUnits = [.minute, .second]
		
		return formatter
	}()
	
	// The formatted string representing the time remaining.
	var timePassedString: String {
		let components = NSDateComponents()
		components.second = Int(max(0.0, timePassed))
		
		return timeFormatter.string(from: components as DateComponents)!
	}
	
	// MARK: Initializers
	
	init(levelScene: GameScene) {
		self.levelScene = levelScene
	}
	
	// MARK: GKState Life Cycle
	
	override func didEnter(from previousState: GKState?) {
		// NSLog("--  LevelSceneActiveState | didEnter from: \(previousState as Any? ?? "--")")
		super.didEnter(from: previousState)
		
		if previousState is LevelSceneSuccessState || previousState is LevelSceneFailState {
			timePassed = 0
		}
		
		levelScene.timerNode.text = timePassedString
		levelScene.gameState = .STARTED
		levelScene.setUserInteraction(true)
	}
	
	override func update(deltaTime seconds: TimeInterval) {
		super.update(deltaTime: seconds)
		
		// Subtract the elapsed time from the remaining time.
		timePassed += seconds
		
		// Update the displayed time remaining.
		levelScene.timerNode.text = timePassedString
				
		//if levelScene.currentLevel.state == .ENDED {
		//	// If all the TaskBots are good, the player has completed the level.
		//	stateMachine?.enter(LevelSceneSuccessState.self)
		//} else if timeRemaining <= 0.0 {
		//	// If there is no time remaining, the player has failed to complete the level.
		//	stateMachine?.enter(LevelSceneFailState.self)
		//}
	}
	
	override func isValidNextState(_ stateClass: AnyClass) -> Bool {
		switch stateClass {
			case is LevelScenePauseState.Type, is LevelSceneFailState.Type, is LevelSceneSuccessState.Type:
				return true
			default:
				return false
		}
	}
}
