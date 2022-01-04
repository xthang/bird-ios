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

class GameViewController: UIViewController {
	
	private static let TAG = "🎮"
	private let TAG = "🎮"
	
	@IBOutlet weak var devBtn: UIButton!
	
	// @IBOutlet weak var masterView: UIView!
	@IBOutlet weak var skView: SKView!
	// @IBOutlet weak var statusBar: StatusBar!
	
	private var adBanner: ADBanner!
	private var adInterstitial: AdInterstitial!
	
	private var lastShowAdInterstitial = Date()
	private var lastShowAdInterstitialGameNo = UserDefaults.standard.integer(forKey: CommonConfig.Keys.gameLevel) - 1
	
	
	override func viewDidLoad() {
		NSLog("--  \(TAG) | viewDidLoad: \(hash)")
		super.viewDidLoad()
		
		if UserDefaults.standard.object(forKey: CommonConfig.Keys.welcomeVersion) == nil {
			showWelcome()
		} else {
			loadScene("viewDidLoad")
		}
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.adsStatusChanged(_:)), name: .AdsStatusChanged, object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.gameLevelFinished), name: .levelFinished, object: nil)
	}
	
	private func showWelcome() {
		let welcomeView = UINib(nibName: "Welcome", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WelcomeView
		welcomeView.onCompletion { [weak self] in
			self?.loadScene("showWelcome")
			
			self?.adsStatusChanged("showWelcome", !Helper.adsRemoved)
		}
		view.addSubview(welcomeView)
	}
	
	private func loadScene(_ tag: String) {
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
				
				// Present the scene
				skView.presentScene(sceneNode)
				
				skView.ignoresSiblingOrder = true
				
				skView.showsFPS = true
				skView.showsDrawCount = true
				skView.showsNodeCount = true
				skView.showsQuadCount = true
				skView.showsPhysics = true
				skView.showsFields = true
				if #available(iOS 13.0, *) {
					skView.showsLargeContentViewer = true
				}
			}
		}
		
		// show welcome on new version update
		let appVersion = Helper.appVersion
		let welcomeVersionRef = UserDefaults.standard.object(forKey: CommonConfig.Keys.welcomeBannerVersion) as? String
		if welcomeVersionRef != appVersion {
			UserDefaults.standard.set(appVersion, forKey: CommonConfig.Keys.welcomeBannerVersion)
			
			if tag != "showWelcome" {
				let alert = PopupAlert.initiate(title: NSLocalizedString("YOUR APP HAS BEEN UPDATED", comment: ""), message: "\(NSLocalizedString("NEW VERSION", comment: "")): \(appVersion)")
				alert.dismissOutside = false
				
				_ = alert.addAction(title: NSLocalizedString("LET'S PLAY", comment: ""), style: .primary1) { [weak self] in
					GameCenterHelper.authenticateLocalPlayer(GameViewController.TAG, self!)
					
					// self?.rewardDaily("loadScene|\(tag)")
				}
				view.addSubview(alert)
				return
			}
		}
		
		GameCenterHelper.authenticateLocalPlayer(TAG, self)
		
		// rewardDaily("loadScene|\(tag)")
	}
	
	override func viewDidAppear(_ animated: Bool) {
		NSLog("--  \(TAG) | viewDidAppear: \(hash) - animated: \(animated)")
		super.viewDidAppear(animated)
		
		if #available(iOS 13.0, *) {
			NotificationCenter.default.removeObserver(self, name: UIScene.willDeactivateNotification, object: view.window!.windowScene!)
			NotificationCenter.default.removeObserver(self, name: UIScene.didActivateNotification, object: view.window!.windowScene!)
			NotificationCenter.default.addObserver(self, selector: #selector(self.deactivate), name: UIScene.willDeactivateNotification, object: view.window!.windowScene!)
			NotificationCenter.default.addObserver(self, selector: #selector(self.activate), name: UIScene.didActivateNotification, object: view.window!.windowScene!)
		} else {
			NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
			NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
			NotificationCenter.default.addObserver(self, selector: #selector(self.deactivate), name: UIApplication.willResignActiveNotification, object: nil)
			NotificationCenter.default.addObserver(self, selector: #selector(self.activate), name: UIApplication.didBecomeActiveNotification, object: nil)
		}
		
		if #available(iOS 13.0, *) {
			self.adBanner = (view.window!.windowScene!.delegate as? SceneDelegate)?.adBanner ?? ADBanner.shared
			self.adInterstitial = (view.window!.windowScene!.delegate as? SceneDelegate)?.adInterstitial ?? AdInterstitial.shared
		} else {
			self.adBanner = ADBanner.shared
			self.adInterstitial = AdInterstitial.shared
		}
		
		if UserDefaults.standard.object(forKey: CommonConfig.Keys.welcomeVersion) != nil {
			adsStatusChanged("viewDidAppear", !Helper.adsRemoved)
		}
	}
	
	override func viewWillTransition(to size: CGSize,
												with coordinator: UIViewControllerTransitionCoordinator) {
		NSLog("--  \(TAG) | viewWillTransition: to size: \(size)")
		super.viewWillTransition(to:size, with:coordinator)
		
		coordinator.animate(alongsideTransition: { [weak self] _ in
			self?.adBanner?.reloadAd("\(self!.TAG)|viewWillTransition")
		})
	}
	
	@objc private func deactivate(_ noti: NSNotification) {
		// NSLog("--  \(TAG) | deactivate: \(hash)")
		
		skView.isPaused = true
		(skView.scene as? BaseScene)?.deactivate("\(TAG)|deactivate", noti)
	}
	
	@objc private func activate(_ noti: NSNotification) {
		// NSLog("--  \(TAG) | activate: \(hash)")
		
		skView.isPaused = false
		(skView.scene as? BaseScene)?.activate("\(TAG)|activate", noti)
		
		adsStatusChanged("activate", !Helper.adsRemoved)
		// if !Helper.isFirstRun { rewardDaily("activate") }
	}
	
	// detect keyboard pressed
	override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
		super.pressesBegan(presses, with: event)
		
		skView.scene?.pressesDidBegin(presses, with: event)
	}
	
	private func updateAdsBanner(_ tag: String, _ on: Bool) {
		if on {
			adBanner?.show("\(TAG)|updateAdsBanner|\(tag)", viewController: self, position: .bottom) // allCases.randomElement()
		} else {
			adBanner?.remove("\(TAG)|updateAdsBanner|\(tag)")
		}
	}
	
	private func adsStatusChanged(_ tag: String, _ on: Bool) {
		NSLog("--  \(TAG) | adsStatusChanged [\(tag)]: on: \(on)")
		
		if on {
			updateAdsBanner("adsStatusChanged|\(tag)", on)
			return
		}
		updateAdsBanner("adsStatusChanged|\(tag)", false)
	}
	
	@objc private func adsStatusChanged(_ notification: NSNotification) {
		adsStatusChanged("notification", notification.object as! Bool)
	}
	
	@objc private func gameLevelFinished(_ notification: NSNotification) {
		NSLog("--  \(TAG) | gameLevelFinished: \(hash) - \(notification.object ?? "--")")
		
		let level = notification.object as! Int
		
		if #available(iOS 10.3, *), level >= 20 && level % 10 == 0 {
			SKStoreReviewController.requestReviewInCurrentScene("\(TAG)|gameLevelFinished")
		}
		
		if Helper.adsRemoved { return }
		
		if level >= 0 {
			updateAdsBanner("gameLevelFinished", true)
		}
	}
	
	func showAdInterstitial(_ tag: String, gameNo: Int) -> Bool {
		if Helper.adsRemoved { return false }
		
		NSLog("--  \(TAG) | showAdInterstitial [\(tag)]: gameNo: \(gameNo) | last: \(lastShowAdInterstitialGameNo) ~ \(lastShowAdInterstitial)")
		
		let d = Date()
		if gameNo >= 4
				&& (((gameNo - 1) % 3 == 0 && d.timeIntervalSince(lastShowAdInterstitial) > 90)
					 || gameNo - lastShowAdInterstitialGameNo >= 4) {
			if adInterstitial.present("\(TAG)|gameLevelFinished", in: self) {
				lastShowAdInterstitial = d
				lastShowAdInterstitialGameNo = gameNo
				return true
			}
		}
		
		return false
	}
}
