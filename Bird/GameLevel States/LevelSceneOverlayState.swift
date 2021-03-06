/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The base class for a `LevelScene`'s Pause, Fail, and Success states. Handles the task of loading and displaying a full-screen overlay from a scene file when the state is entered.
 */

import SpriteKit
import GameplayKit

import XLibrary

class LevelSceneOverlayState: GKState {
	// MARK: Properties
	
	private let TAG = "\(LevelSceneOverlayState.self)"
	
	unowned let levelScene: GameScene
	
	/// The `SceneOverlay` to display when the state is entered.
	var overlay: SceneOverlay!
	
	/// Overridden by subclasses to provide the name of the .sks file to load to show as an overlay.
	var overlaySceneFileName: String { fatalError("Unimplemented overlaySceneName") }
	
	// MARK: Initializers
	
	init(levelScene: GameScene) {
		self.levelScene = levelScene
		
		super.init()
		
		overlay = SceneOverlay.initiate(fileName: overlaySceneFileName)
	}
	
	// MARK: GKState Life Cycle
	
	override func didEnter(from previousState: GKState?) {
		// NSLog("--  \(type(of: self)) | didEnter from: \(previousState as Any? ?? "--")")
		super.didEnter(from: previousState)
		
		// levelScene.root.isUserInteractionEnabled = false
		levelScene.root.speed = 0
		levelScene.physicsWorld.speed = 0

		levelScene.show(overlay)
	}
	
	override func willExit(to nextState: GKState) {
		// NSLog("--  \(type(of: self)) | willExit to: \(nextState)")
		super.willExit(to: nextState)
		
		//overlay.run(SKAction.fadeOut(withDuration: 0.25)) { [weak self] in
		//	self?.overlay.removeFromParent()
		//}
		overlay.removeFromParent("\(type(of: self))|willExit")
	}
}
