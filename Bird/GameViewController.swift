//
//  GameViewController.swift
//  Bird
//
//  Created by Thang Nguyen on 12/28/21.
//

import UIKit
import SpriteKit
import GameplayKit
import StoreKit

import XLibrary

class GameViewController: BaseGameViewController {
	
	private static let TAG = "🎮"
	private let TAG = "🎮"
	
	private var lastShowAdInterstitialGameNo = UserDefaults.standard.integer(forKey: CommonConfig.Keys.gamesCount) - 1
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	
	override func viewDidLoad() {
		NSLog("--  \(TAG) | viewDidLoad: \(hash)")
		super.viewDidLoad()
		
		canShowWelcome = true
		
		welcomeView = UINib(nibName: "Welcome", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WelcomeView
		
		// Load 'GameScene.sks' as a GKScene. This provides gameplay related content
		// including entities and graphs.
		if let scene = GKScene(fileNamed: "HomeScene") {
			
			// Get the SKScene from the loaded GKScene
			if let sceneNode = scene.rootNode as! HomeScene? {
				
				// Copy gameplay related content over to the scene
				sceneNode.entities = scene.entities
				sceneNode.graphs = scene.graphs
				
				// Set the scale mode to scale to fit the window
				// sceneNode.scaleMode = .resizeFill
				
				homeScene = sceneNode
			}
		}
		
		// game count is incremented, so dont do this
		// SceneManager.prepareScene(.game)
	}
	
	override func homeEntered(_ notification: NSNotification) {
		super.homeEntered(notification)
		
		if Helper.adsRemoved { return }
		
		checkAndUpdateAdsBanner("homeEntered", true, position: .top)
	}
	
	override func gameEntered(_ notification: NSNotification) {
		super.gameEntered(notification)

		canShowAds = false
		
		updateAdsBanner("gameEntered", false)
	}
	
	override func gameFinished(_ notification: NSNotification) {
		super.gameFinished(notification)
		
		let level = notification.object as! Int
		
		if #available(iOS 10.3, *), level >= 20 && (level + 30) % 50 == 0 {
			SKStoreReviewController.requestReviewInCurrentScene("\(TAG)|gameFinished")
		}
		
		if Helper.adsRemoved { return }
		
		if level >= 0 {
			updateAdsBanner("gameFinished", true, position: .bottom)
		}
	}
	
	override func showAdInterstitial(_ tag: String, gameNo: Int) -> Bool {
		if Helper.adsRemoved { return false }
		
		NSLog("--  \(TAG) | showAdInterstitial [\(tag)]: gameNo: \(gameNo) | last: \(lastShowAdInterstitialGameNo) ~ \(lastShowAdInterstitial)")
		
		let d = Date()
		if gameNo >= 20
				&& (((gameNo - 0) % 10 == 0 && d.timeIntervalSince(lastShowAdInterstitial) > 90)
					 || gameNo - lastShowAdInterstitialGameNo >= 12) {
			if adInterstitial.present("\(TAG)|gameLevelFinished", in: self) {
				lastShowAdInterstitial = d
				lastShowAdInterstitialGameNo = gameNo
				return true
			}
		}
		
		return false
	}
}
