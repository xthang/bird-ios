//
//  Created by Thang Nguyen on 10/15/21.
//

import SpriteKit
import GameplayKit
import AVFoundation

import XLibrary

enum GameLayer: CGFloat {
	case background = 0
	case objects = 1
	
	enum ObjectLayer: CGFloat {
		case sky = 0
		case obstacle = 1
		case ground = 20
	}
	
	case mainCharacter = 10
	case score = 80
	case tutorial = 90
	case navigation = 99
}

class GameScene: BaseScene {
	
	private let TAG = "🎰"
	
	enum State: Int {
		case PREPARED, STARTED, PAUSED, ENDED, FINISHED
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
		LevelSceneFinishState(levelScene: self)
	])
	
	var score : Int = -1 {
		didSet {
			scoreLabel.text = "\(score)"
		}
	}
	
	// Calculation
	private var MAIN_CHARACTER_HEIGHT: CGFloat!
	private var GROUND_HEIGHT_ON_DISPLAY: CGFloat!
	private var PIPE_WIDTH: CGFloat!
	private var VERTICAL_PIPE_GAP: CGFloat!
	private var VELOCITY: CGFloat!
	private var BG_VELOCITY: CGFloat!
	
	// Nodes
	lazy var root = childNode(withName: "game")!
	private lazy var navigation = root.childNode(withName: "Navigation")!
	// lazy var timerNode = root.childNode(withName: "Time") as! SKLabelNode
	
	private lazy var scoreLabel = root.childNode(withName: "Score") as! SKLabelNode2
	private lazy var tutorial = root.childNode(withName: "Tutorial")!
	
	private lazy var mainCharacter = root.childNode(withName: "MainCharacter") as! SKSpriteNode
	
	private lazy var movingObjects = root.childNode(withName: "MovingObjects")!
	private lazy var movingObstacles = movingObjects.childNode(withName: "MovingObstacles")!
	
	// Node templates
	private let groundObstacleTemp1 = SKSpriteNode(imageNamed: "pipe_up_1")
	private let groundObstacleTemp2 = SKSpriteNode(imageNamed: "pipe_up_2")
	private let skyObstacleTemp1 = SKSpriteNode(imageNamed: "pipe_down_1")
	private let skyObstacleTemp2 = SKSpriteNode(imageNamed: "pipe_down_2")
	
	// Physics
	private let birdCategory: UInt32 = 1 << 0
	private let groundCategory: UInt32 = 1 << 1
	private let pipeCategory: UInt32 = 1 << 2
	private let scoreCategory: UInt32 = 1 << 3
	
	// Actions
	private var movePipesAndRemove: SKAction!
	
	// FX - sounds
	private let flapSound = SKAudioNode(fileNamed: "sfx_wing")
	private let hitSound = SKAudioNode(fileNamed: "sfx_hit")
	private let dieSound = SKAudioNode(fileNamed: "sfx_die")
	private let scoringSound = SKAudioNode(fileNamed: "sfx_point")
	// FX - vibration
	private let notiFeedbackGenerator = UINotificationFeedbackGenerator()
	private var impactFeedbackGenerator: UIImpactFeedbackGenerator!
	
	private var endGameAction: ((Int)->Void)?
	
	
	override func sceneDidLoad() {
		super.sceneDidLoad()
		
		initFX("sceneDidLoad")
		initObjects("sceneDidLoad")
		
		loadGame("sceneDidLoad")
	}
	
	override func didMove(to view: SKView) {
		super.didMove(to: view)
		
		resizeScene("didMove")
		// sceneStartEffect("didMove")
		
		// Move to the active state, starting the level timer.
		stateMachine.enter(LevelSceneActiveState.self)
		
		sceneLoaded = true
		
		NotificationCenter.default.post(name: .levelEntered, object: gameNo)
	}
	
	override func didChangeSize(_ oldSize: CGSize) {
		super.didChangeSize(oldSize)
		
		scaleMode = .aspectFit
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
		if gameState == .STARTED || gameState == .ENDED {
			// update bird rotation
			let verticalVelocity = mainCharacter.physicsBody!.velocity.dy
			let rotation = (verticalVelocity + MAIN_CHARACTER_HEIGHT * 12) * ((verticalVelocity + MAIN_CHARACTER_HEIGHT * 12) > 0 ? 0.01 : 0.0025)
			mainCharacter.zRotation = min( max(-1.5, rotation), 0.35 )
		}
		
		// Update the level's state machine.
		if gameState == .STARTED {
			stateMachine.update(deltaTime: dt)
		}
		
		self.lastUpdateTime = currentTime
	}
	
	private func initFX(_ tag: String) {
		if !sounds.isEmpty { fatalError("!-  already init FX") }
		
		sounds += [flapSound, hitSound, dieSound, scoringSound]
		
		let vol = Helper.soundVolume
		sounds.forEach {
			$0.autoplayLooped = false
			$0.run(SKAction.changeVolume(to: vol, duration: 0))
			addChild($0)
		}
		
		let style: UIImpactFeedbackGenerator.FeedbackStyle
		if #available(iOS 13.0, *) { style = .soft } else { style = .light }
		impactFeedbackGenerator = UIImpactFeedbackGenerator(style: style)
	}
	
	private func initObjects(_ tag: String) {
		// print("--  \(TAG) | initObjects [\(tag)]")
		
		// Physics
		physicsWorld.contactDelegate = self
		
		navigation.zPosition = GameLayer.navigation.rawValue
		
		scoreLabel.fontTextureAtlas = SKTextureAtlas(named: "number_score")
		scoreLabel.fontMap = { atlas, c in
			return atlas.textureNamed("number_score_0\(c)")
		}
		scoreLabel.zPosition = GameLayer.score.rawValue
		
		let tutorialTap = tutorial.childNode(withName: "tap-tap") as! SKSpriteNode
		tutorialTap.texture!.filteringMode = .nearest
		let tutorialReady = tutorial.childNode(withName: "get-ready") as! SKSpriteNode
		tutorialReady.texture!.filteringMode = .nearest
		tutorial.zPosition = GameLayer.tutorial.rawValue
		
		// Bird
		mainCharacter.zPosition = GameLayer.mainCharacter.rawValue
		let mainCharTextureAtlas = SKTextureAtlas(named: "bird\([0, 1, 2].randomElement()!)")
		mainCharacter.texture = mainCharTextureAtlas.textureNamed(mainCharTextureAtlas.textureNames.first!)
		let anim = SKAction.animate(with: mainCharTextureAtlas.textureNames.map {
			let t = mainCharTextureAtlas.textureNamed($0)
			t.filteringMode = .nearest
			return t
		}, timePerFrame: 0.08)
		let flap = SKAction.repeatForever(anim)
		mainCharacter.run(flap, withKey: "flap")
		
		// Pipes
		movingObjects.zPosition = GameLayer.objects.rawValue
		
		movingObstacles.speed = 0
		
		groundObstacleTemp1.texture!.filteringMode = .nearest
		groundObstacleTemp2.texture!.filteringMode = .nearest
		skyObstacleTemp1.texture!.filteringMode = .nearest
		skyObstacleTemp2.texture!.filteringMode = .nearest
	}
	
	private func loadGame(_ tag: String) {
		gameNo = UserDefaults.standard.integer(forKey: CommonConfig.Keys.gamesCount) + 1
		
		NSLog("--  \(TAG) | loadGame [\(tag)]: \(gameNo!)")
		
		UserDefaults.standard.set(gameNo, forKey: CommonConfig.Keys.gamesCount)
		
		score = 0
	}
	
	private func resizeScene(_ tag: String) {
		NSLog("--  \(TAG) | resizeScene [\(tag)]: \(frame)")
		
		// Bird
		let mainCharTextureSize = mainCharacter.texture!.size()
		mainCharacter.setScale(min(frame.width * 0.12 / mainCharTextureSize.width, frame.height * 0.06 / mainCharTextureSize.height))
		mainCharacter.position = CGPoint(x: self.frame.width * -0.2, y: self.frame.height * 0)
		
		mainCharacter.physicsBody = SKPhysicsBody(circleOfRadius: mainCharacter.size.height / 2.0)
		mainCharacter.physicsBody!.isDynamic = false
		mainCharacter.physicsBody!.allowsRotation = false
		mainCharacter.physicsBody!.mass = 1
		
		mainCharacter.physicsBody!.categoryBitMask = birdCategory
		mainCharacter.physicsBody!.collisionBitMask = groundCategory | pipeCategory
		mainCharacter.physicsBody!.contactTestBitMask = groundCategory | pipeCategory
		
		let hop = SKAction.moveBy(x: 0, y: mainCharacter.size.height * 0.5, duration: 0.3)
		mainCharacter.run(SKAction.repeatForever(SKAction.sequence([hop, hop.reversed()])), withKey: "hop")
		
		MAIN_CHARACTER_HEIGHT = mainCharacter.size.height
		let MAIN_CHARACTER_WIDTH = mainCharacter.size.width
		
		physicsWorld.gravity = CGVector(dx: 0, dy: -MAIN_CHARACTER_HEIGHT * 0.35)
		
		PIPE_WIDTH = MAIN_CHARACTER_WIDTH * 52 / 34
		VERTICAL_PIPE_GAP = MAIN_CHARACTER_HEIGHT * 4.295
		VELOCITY = MAIN_CHARACTER_WIDTH * 4
		BG_VELOCITY = MAIN_CHARACTER_WIDTH * 0.2
		
		// background
		let background = movingObjects.childNode(withName: "background")!
		background.removeAllChildren()
		background.zPosition = GameLayer.ObjectLayer.sky.rawValue
		
		let bgTexture = SKTexture(imageNamed: "bg_day")
		bgTexture.filteringMode = .nearest
		
		let bgTextureSize = bgTexture.size()
		let bgSize = CGSize(width: max(frame.width, frame.height * bgTextureSize.width / bgTextureSize.height),
								  height: max(frame.height, frame.width * bgTextureSize.height / bgTextureSize.width))
		
		let moveBg = SKAction.moveBy(x: -bgSize.width, y: 0, duration: TimeInterval(bgSize.width / BG_VELOCITY))
		let resetBg = SKAction.moveBy(x: bgSize.width, y: 0, duration: 0.0)
		let moveBgsForever = SKAction.repeatForever(SKAction.sequence([moveBg, resetBg]))
		
		for i in 0 ..< 2 + Int(self.frame.width / ( bgTexture.size().width * 2 )) {
			let node = SKSpriteNode(texture: bgTexture)
			
			node.size = bgSize
			node.position = CGPoint(x: CGFloat(i) * node.size.width, y: 0)
			
			node.run(moveBgsForever)
			
			background.addChild(node)
		}
		
		// ground
		let grounds = movingObjects.childNode(withName: "ground")!
		grounds.zPosition = GameLayer.ObjectLayer.ground.rawValue
		grounds.removeAllChildren()
		
		let groundTexture = SKTexture(imageNamed: "land")
		groundTexture.filteringMode = .nearest
		
		let groundTextureSize = groundTexture.size()
		let groundSize = CGSize(width: frame.width,
										height: frame.width * groundTextureSize.height / groundTextureSize.width)
		GROUND_HEIGHT_ON_DISPLAY = min(groundSize.height, frame.height * 0.2)
		
		let moveGround = SKAction.moveBy(x: -groundSize.width, y: 0, duration: TimeInterval(groundSize.width / VELOCITY))
		let resetGround = SKAction.moveBy(x: groundSize.width, y: 0, duration: 0.0)
		let moveGroundsForever = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))
		
		for i in 0 ... 1 + Int(self.frame.height / groundSize.width) {
			let ground = SKSpriteNode(texture: groundTexture)
			ground.name = "ground"
			ground.size = groundSize
			ground.position = CGPoint( x: CGFloat(i) * ground.size.width, y: -frame.height/2 - ground.size.height/2 + GROUND_HEIGHT_ON_DISPLAY )
			
			ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
			ground.physicsBody!.isDynamic = false
			ground.physicsBody!.categoryBitMask = groundCategory
			//ground.physicsBody!.collisionBitMask = collisionCategory
			//ground.physicsBody!.contactTestBitMask = collisionCategory
			
			ground.run(moveGroundsForever)
			
			grounds.addChild(ground)
		}
		
		// Sky contact
		let sky = SKNode()
		sky.name = "sky"
		sky.position = CGPoint(x: 0, y: frame.height * 0.5 + MAIN_CHARACTER_HEIGHT)
		sky.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: frame.width, height: 1))
		sky.physicsBody!.isDynamic = false
		sky.physicsBody!.categoryBitMask = pipeCategory
		addChild(sky)
		
		// Pipes
		let groundPipeTexture1Size = groundObstacleTemp1.texture!.size()
		groundObstacleTemp1.name = "ground-pipe-1"
		groundObstacleTemp1.size = CGSize(width: PIPE_WIDTH, height: PIPE_WIDTH * groundPipeTexture1Size.height / groundPipeTexture1Size.width)
		let groundPipeTexture2Size = groundObstacleTemp2.texture!.size()
		groundObstacleTemp2.name = "ground-pipe-2"
		groundObstacleTemp2.size = CGSize(width: PIPE_WIDTH, height: PIPE_WIDTH * groundPipeTexture2Size.height / groundPipeTexture2Size.width)
		let skyPipeTexture1Size = skyObstacleTemp1.texture!.size()
		skyObstacleTemp1.name = "sky-pipe-1"
		skyObstacleTemp1.size = CGSize(width: PIPE_WIDTH, height: PIPE_WIDTH * skyPipeTexture1Size.height / skyPipeTexture1Size.width)
		let skyPipeTexture2Size = skyObstacleTemp2.texture!.size()
		skyObstacleTemp2.name = "sky-pipe-2"
		skyObstacleTemp2.size = CGSize(width: PIPE_WIDTH, height: PIPE_WIDTH * skyPipeTexture2Size.height / skyPipeTexture2Size.width)
		
		let spawnThenDelayForever = SKAction.repeatForever(SKAction.sequence([
			SKAction.run { [weak self] in self!.spawnObstacles("") },
			SKAction.wait(forDuration: PIPE_WIDTH * 3 / VELOCITY)
		]))
		movingObstacles.run(SKAction.sequence([
			SKAction.wait(forDuration: 2),
			spawnThenDelayForever
		]), withKey: "spawn")
		
		// create the pipes movement actions
		let distanceToMove = frame.width + PIPE_WIDTH
		let movePipes = SKAction.moveBy(x: -distanceToMove, y: 0, duration: TimeInterval(distanceToMove / VELOCITY))
		let removePipes = SKAction.removeFromParent()
		movePipesAndRemove = SKAction.sequence([movePipes, removePipes])
		
		scoreLabel.fontSize = min(frame.width * 0.1, frame.height * 0.04)
		scoreLabel.textSpace = scoreLabel.fontSize * 0.1
		scoreLabel.position = CGPoint(x: 0, y: frame.height * 0.35)
		
		let tutorialTap = tutorial.childNode(withName: "tap-tap") as! SKSpriteNode
		tutorialTap.setScale(mainCharacter.xScale)
		
		let tutorialReady = tutorial.childNode(withName: "get-ready") as! SKSpriteNode
		tutorialReady.setScale(mainCharacter.xScale)
		tutorialReady.position.y = tutorialTap.frame.maxY + frame.height * 0.04 + tutorialReady.size.height / 2
		
		tutorial.position.y = frame.height * -0.02
		
		let navHeight = min(frame.height * 0.03, frame.width * 0.09)
		navigation.position = CGPoint(x: 0, y: frame.height * 0.45)
		let pauseBtn = navigation.childNode(withName: "Pause") as! ButtonNode
		let pauseImg = pauseBtn.imgNode!
		pauseImg.size = CGSize(width: navHeight * 1.6 * pauseImg.texture!.size().width / pauseImg.texture!.size().height, height: navHeight * 1.6)
		pauseBtn.size = CGSize(width: navHeight * 1.7, height: navHeight * 1.7)
		pauseBtn.position = CGPoint(x: -frame.width * 0.4, y: 0)
		
		// updateScene("resizeScene|\(tag)")
	}
	
	private func spawnObstacles(_ tag: String) {
		let pipePair = SKNode()
		pipePair.position = CGPoint( x: (frame.width + PIPE_WIDTH) / 2, y: 0 )
		pipePair.zPosition = GameLayer.ObjectLayer.obstacle.rawValue
		
		let height = UInt32(MAIN_CHARACTER_HEIGHT * 8)
		let y: CGFloat = -MAIN_CHARACTER_HEIGHT * 4 + CGFloat(arc4random_uniform(height))
		
		let pipeDown = skyObstacleTemp1.copy() as! SKSpriteNode
		pipeDown.position = CGPoint(x: 0, y: (GROUND_HEIGHT_ON_DISPLAY + VERTICAL_PIPE_GAP + pipeDown.size.height) / 2 + y)
		
		pipeDown.physicsBody = SKPhysicsBody(rectangleOf: pipeDown.size)
		pipeDown.physicsBody!.isDynamic = false
		pipeDown.physicsBody!.categoryBitMask = pipeCategory
		pipeDown.physicsBody!.contactTestBitMask = birdCategory
		pipePair.addChild(pipeDown)
		
		let pipeUp = groundObstacleTemp1.copy() as! SKSpriteNode
		pipeUp.position = CGPoint(x: 0, y: (GROUND_HEIGHT_ON_DISPLAY - VERTICAL_PIPE_GAP - pipeUp.size.height) / 2 + y)
		
		pipeUp.physicsBody = SKPhysicsBody(rectangleOf: pipeUp.size)
		pipeUp.physicsBody!.isDynamic = false
		pipeUp.physicsBody!.categoryBitMask = pipeCategory
		pipeUp.physicsBody!.contactTestBitMask = birdCategory
		pipePair.addChild(pipeUp)
		
		let contactNode = SKNode()
		contactNode.name = "score"
		contactNode.position = CGPoint( x: pipeDown.size.width * 0.5, y: self.frame.midY )
		contactNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize( width: 1, height: self.frame.height ))
		contactNode.physicsBody!.isDynamic = false
		contactNode.physicsBody!.categoryBitMask = scoreCategory
		contactNode.physicsBody!.contactTestBitMask = birdCategory
		pipePair.addChild(contactNode)
		
		pipePair.run(movePipesAndRemove)
		movingObstacles.addChild(pipePair)
	}
	
	private func startGame(_ tag: String) {
		movingObstacles.speed = 1
		
		backgroundSoundPlayer?.stop()
		// playSound(gameStartSound)
		
		tutorial.run(SKAction.sequence([
			SKAction.fadeOut(withDuration: 0.3),
			SKAction.removeFromParent()
		]))
		
		mainCharacter.removeAction(forKey: "hop")
		mainCharacter.physicsBody!.isDynamic = true
		
		gameState = .STARTED
		
		NSLog("--  \(TAG) | Game started")
	}
	
	override func pause(_ tag: String) {
		super.pause(tag)
		
		stateMachine.enter(LevelScenePauseState.self)
	}
	
	override func resume(_ tag: String) {
		super.resume(tag)
		
		stateMachine.enter(LevelSceneActiveState.self)
	}
	
	func onEndGame(action: @escaping (Int)->Void) {
		endGameAction = action
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		processInput("touch")
	}
	
	override func pressesDidBegin(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
		// NSLog("--  \(TAG) | pressesDidBegin: \(presses.map { p in p.key?.charactersIgnoringModifiers })")
		
		guard let _ = presses.first?.key else { return }
		
		processInput("press")
	}
	
	private func processInput(_ tag: String) {
		if !isUserInteractionEnabled {
			NSLog("!-  \(TAG) | processInput: \(isUserInteractionEnabled)")
			return
		}
		
		if gameState == .PREPARED {
			startGame("input|\(tag)")
		} else if gameState == .PAUSED {
			resume("input|\(tag)")
		}
		
		if gameState == .STARTED {
			mainCharacter.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
			mainCharacter.physicsBody!.applyImpulse(CGVector(dx: 0, dy: mainCharacter.physicsBody!.mass * MAIN_CHARACTER_HEIGHT * 17))
			flapSound.removeAllActions()
			playSound(flapSound)
		}
	}
	
	private func endGame(_ tag: String) {
		if gameState == .ENDED { return }
		NSLog("--  \(TAG) | endGame [\(tag)]")
		
		gameState = .ENDED
		setUserInteraction(false)
		
		vibrate(impactFeedbackGenerator)
		playSound(hitSound)
		
		movingObjects.speed = 0
		
		mainCharacter.physicsBody!.collisionBitMask = groundCategory // in case bird lands on top of pipe
		mainCharacter.physicsBody!.velocity.dx = 0
		
		playSound(dieSound, delay: 0.3)
	}
	
	private func finishScene(_ tag: String) {
		if gameState == .FINISHED { fatalError("!-  game already finished") }
		NSLog("--  \(TAG) | finishScene [\(tag)]")
		
		gameState = .FINISHED
		
		mainCharacter.speed = 0
		physicsWorld.speed = 0
		
		dieSound.removeAllActions()
		
		let background = movingObjects.childNode(withName: "background")!
		backgroundColor = SKColor(red: 0.1, green: 0, blue: 0.1, alpha: 1.0)
		run(SKAction.sequence([
			SKAction.repeat(SKAction.sequence([
				SKAction.run { background.alpha = 0.7 },
				SKAction.wait(forDuration: 0.1),
				SKAction.run { background.alpha = 1 },
				SKAction.wait(forDuration: 0.1)
			]), count: 3),
			SKAction.wait(forDuration: 0.8),
		])) { [weak self] in
			self!.root.speed = 0
			self!.scoreLabel.isHidden = true
			
			let _ = ScoreData.insert(self!.TAG, Score(self!.score))
			GameCenterHelper.reportAchievement(self!.TAG, "game_\(self!.gameNo!)")
			GameCenterHelper.reportAchievement(self!.TAG, "score_\(self!.gameNo!)")
			GameCenterHelper.submitScore(self!.TAG, self!.score)
			
			self!.stateMachine.enter(LevelSceneFinishState.self)
			
			NotificationCenter.default.post(name: .levelFinished, object: self!.gameNo)
			
			self!.endGameAction?(self!.score)
		}
	}
}

extension GameScene: SKPhysicsContactDelegate {
	
	func didBegin(_ contact: SKPhysicsContact) {
		print("--  \(TAG) | physics contact: \(contact.bodyA.node!.name!) >< \(contact.bodyB.node!.name!) | \(gameState)")
		
		if gameState != .ENDED && gameState != .FINISHED {
			if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory
					|| (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
				score += 1
				playSound(scoringSound)
			} else if (contact.bodyA.categoryBitMask & pipeCategory) == pipeCategory
							|| (contact.bodyB.categoryBitMask & pipeCategory) == pipeCategory {
				endGame("PhysicsContact|1")
			}
		}
		if gameState != .FINISHED
				&& ((contact.bodyA.categoryBitMask & groundCategory) == groundCategory
					 || (contact.bodyB.categoryBitMask & groundCategory) == groundCategory) {
			endGame("PhysicsContact|2")
			finishScene("PhysicsContact")
		}
	}
}
