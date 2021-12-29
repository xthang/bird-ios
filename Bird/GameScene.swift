//
//  Created by Thang Nguyen on 10/15/21.
//

import SpriteKit
import GameplayKit
import AVFoundation

import XLibrary

class GameScene: BaseScene {
	
	private let TAG = "🎰"
	
	enum State: Int {
		case PREPARED, STARTED, PAUSED, ENDED
	}
	enum Direction: String, CaseIterable {
		case UP, DOWN, RIGHT, LEFT
	}
	
	private var sceneLoaded = false
	
	private (set) var gameNo: Int!
	var gameState: State = .PREPARED
	
	private var lastUpdateTime : TimeInterval = 0
	
	private lazy var stateMachine = GKStateMachine(states: [
		LevelSceneActiveState(levelScene: self),
		LevelScenePauseState(levelScene: self),
		LevelSceneSuccessState(levelScene: self),
		LevelSceneFailState(levelScene: self)
	])
	
	private lazy var navigation: SKNode! = childNode(withName: "Navigation")!
	lazy var timerNode: SKLabelNode! = childNode(withName: "Time") as? SKLabelNode
	
	private lazy var levelNode = childNode(withName: "Level") as! SKLabelNode
	
	private var tutorialLayer: SKNode?
	private var hand: SKSpriteNode?
	// private var pathEmitter: SKEmitterNode?
	
	private var gameStartSound: SKAudioNode!
	private var swipeSound: SKAudioNode!
	private var backSound: SKAudioNode!
	private var winSound: SKAudioNode!
	private var hintSound: SKAudioNode!
	private var notiFeedbackGenerator: UINotificationFeedbackGenerator?
	private var impactFeedbackGenerator: UIImpactFeedbackGenerator?
	
	private var endGameAction: ((Int?)->Void)?
	
	
	override func sceneDidLoad() {
		NSLog("--  \(TAG) | sceneDidLoad: \(hash) | \(frame)")
		super.sceneDidLoad()
		
		self.lastUpdateTime = 0
		
		gameStartSound = SKAudioNode(url: Bundle.main.url(forResource: "game-start", withExtension: "wav")!)
		swipeSound = SKAudioNode(url: Bundle.main.url(forResource: "swipe", withExtension: "wav")!)
		backSound = SKAudioNode(url: Bundle.main.url(forResource: "swipe", withExtension: "wav")!)
		winSound = SKAudioNode(url: Bundle.main.url(forResource: "winning", withExtension: "wav")!)
		hintSound = SKAudioNode(url: Bundle.main.url(forResource: "hint", withExtension: "wav")!)
		
		sounds += [gameStartSound, swipeSound, backSound, winSound, hintSound]
		
		let vol = Helper.soundVolume
		sounds.forEach {
			$0.autoplayLooped = false
			$0.run(SKAction.changeVolume(to: vol, duration: 0))
			addChild($0)
		}
		
		if #available(iOS 10.0, *) {
			notiFeedbackGenerator = UINotificationFeedbackGenerator()
			let style: UIImpactFeedbackGenerator.FeedbackStyle
			if #available(iOS 13.0, *) { style = .soft } else { style = .light }
			impactFeedbackGenerator = UIImpactFeedbackGenerator(style: style)
		}
		
		loadGame("sceneDidLoad")
	}
	
	private var swipeU: UISwipeGestureRecognizer!,
					swipeD: UISwipeGestureRecognizer!,
					swipeR: UISwipeGestureRecognizer!,
					swipeL: UISwipeGestureRecognizer!
	
	override func didMove(to view: SKView) {
		// NSLog("--  \(TAG) | didMove to view | \(size)")
		super.didMove(to: view)
		
		resizeScene("didMove")
		sceneStartEffect("didMove")
		
		swipeU = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeHandler(_:)))
		swipeU.cancelsTouchesInView = false
		swipeU.direction = .up
		view.addGestureRecognizer(swipeU)
		
		swipeD = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeHandler(_:)))
		swipeD.cancelsTouchesInView = false
		swipeD.direction = .down
		view.addGestureRecognizer(swipeD)
		
		swipeR = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeHandler(_:)))
		swipeR.cancelsTouchesInView = false
		swipeR.direction = .right
		view.addGestureRecognizer(swipeR)
		
		swipeL = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeHandler(_:)))
		swipeL.cancelsTouchesInView = false
		swipeL.direction = .left
		view.addGestureRecognizer(swipeL)
		
		// Move to the active state, starting the level timer.
		stateMachine.enter(LevelSceneActiveState.self)
		
		sceneLoaded = true
	}
	
	override func willMove(from view: SKView) {
		// NSLog("--  \(TAG) | willMove from view")
		super.willMove(from: view)
		
		view.removeGestureRecognizer(swipeU)
		view.removeGestureRecognizer(swipeD)
		view.removeGestureRecognizer(swipeR)
		view.removeGestureRecognizer(swipeL)
	}
	
	override func didChangeSize(_ oldSize: CGSize) {
		// NSLog("--  \(TAG) | didChangeSize: \(view?.frame as Any? ?? "--") | \(frame)")
		super.didChangeSize(oldSize)
		
		// scaleMode = .aspectFit
		if sceneLoaded { resizeScene("didChangeSize") }
	}
	
	override func update(_ currentTime: TimeInterval) {
		// Called before each frame is rendered
		
		// Initialize _lastUpdateTime if it has not already been
		if (self.lastUpdateTime == 0) {
			self.lastUpdateTime = currentTime
		}
		
		// Calculate time since last update
		let dt = currentTime - self.lastUpdateTime
		
		// Update entities
		for entity in self.entities {
			entity.update(deltaTime: dt)
		}
		
		// Update the level's state machine.
		if gameState == .STARTED {
			stateMachine.update(deltaTime: dt)
		}
		
		self.lastUpdateTime = currentTime
	}
	
	private func loadGame(_ tag: String) {
		gameNo = UserDefaults.standard.integer(forKey: CommonConfig.Keys.gamesCount) + 1
		
		NSLog("--  \(TAG) | loadGame [\(tag)]: \(gameNo!)")
		
		UserDefaults.standard.set(gameNo, forKey: CommonConfig.Keys.gamesCount)
		
		setupScene("loadLevel|\(tag)")
	}
	
	private func setupScene(_ tag: String) {
		
	}
	
	private func resizeScene(_ tag: String) {
		NSLog("--  \(TAG) | resizeScene [\(tag)]")
		
		updateScene("resizeScene|\(tag)")
	}
	
	public func updateScene(_ tag: String) {
		// NSLog("--  \(TAG) | updateScene [\(tag)]")
		
	}
	
	private func sceneStartEffect(_ tag: String, completion: (()->Void)? = nil) {
		
	}
	
	private func animateHand(_ tag: String) {
		// print("--  \(TAG) | animateHand [\(tag)]: \(currentLevel.solDirection.count) - \(currentLevel.track.count)")
		
	}
	
	override func pause(_ tag: String) {
		super.pause(tag)
		
		stateMachine.enter(LevelScenePauseState.self)
	}
	
	override func resume(_ tag: String) {
		super.resume(tag)
		
		stateMachine.enter(LevelSceneActiveState.self)
	}
	
	func onEndGame(action: @escaping (Int?)->Void) {
		endGameAction = action
	}
	
	@objc private func swipeHandler(_ gestureRecognizer : UISwipeGestureRecognizer) {
		if !isUserInteractionEnabled
				|| gameState != .STARTED || gestureRecognizer.state != .ended { return }
		
		// NSLog("--  \(TAG) | swiped: \(gestureRecognizer.direction.rawValue)")
		
		let d = gestureRecognizer.direction
		let direction : Direction? = d == .up ? .UP : d == .down ? .DOWN : d == .left ? .LEFT : d == .right ? .RIGHT : nil
		if direction != nil {
			processInput("swipe", direction!)
		}
	}
	
	// detect keyboard pressed
	override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
		NSLog("--  \(TAG) | pressesBegan: \(presses.map { p in p.key?.charactersIgnoringModifiers })")
		super.pressesBegan(presses, with: event)
	}
	
	override func pressesDidBegin(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
		// NSLog("--  \(TAG) | doPressesBegan: \(presses.map { p in p.key?.charactersIgnoringModifiers })")
		
		if !isUserInteractionEnabled
				|| gameState != .STARTED { return }
		guard let key = presses.first?.key
		else { return }
		
		let k = key.keyCode
		let direction : Direction? = k == .keyboardUpArrow ? .UP : k == .keyboardDownArrow ? .DOWN : k == .keyboardLeftArrow ? .LEFT : k == .keyboardRightArrow ? .RIGHT : nil
		if direction != nil {
			processInput("press", direction!)
		}
	}
	
	private func processInput(_ tag: String, _ direction: Direction) {
		
		
		if gameState == .ENDED {
			endGame(tag)
		}
	}
	
	private func endGame(_ tag: String) {
		setUserInteraction(false)
		finishScene(tag)
	}
	
	private func finishScene(_ tag: String) {
		NSLog("--  \(TAG) | finishScene [\(tag)]")
		
		vibrate(impactFeedbackGenerator)
		playSound(winSound)
		
		let oldColor = backgroundColor
		let newColor = UIColor.rgb(0xf6cd61)
		// let background = self.childNode(withName: "background") as! SKSpriteNode
		run(SKAction.sequence([
			SKAction.repeat(SKAction.sequence([
				SKAction.run { [weak self] in self?.backgroundColor = newColor },
				SKAction.wait(forDuration: 0.1),
				SKAction.run { [weak self] in self?.backgroundColor = oldColor },
				SKAction.wait(forDuration: 0.1)
			]), count: 2),
			SKAction.wait(forDuration: 0.8),
		])) { [weak self] in
			if self == nil { return }
			// self!.speed = 0
			// self!.scoreLabel?.isHidden = true
			
			// let _ = ScoreData.insert(Score(self!.score))
			// GameCenterHelper.submitScore(self!.score)
			
			self!.stateMachine.enter(LevelSceneSuccessState.self)
			
			NotificationCenter.default.post(name: .levelFinished, object: self!.gameNo)
			
			self!.endGameAction?(0)
		}
	}
	
	override func buttonTriggered(_ button: IButton) {
		switch button.buttonIdentifier! {
			case .pause:
				pause(button.buttonIdentifier!.rawValue)
			default:
				super.buttonTriggered(button)
		}
	}
}
