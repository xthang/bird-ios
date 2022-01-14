//
//  Created by Thang Nguyen on 12/7/21.
//

import UIKit
import XLibrary
import SpriteKit

class GameFinishScene: SceneOverlay {
	
	private let TAG = "\(GameFinishScene.self)"
	
	private var gameNo: Int!
	private var score: Int = -1
	private var newBestScore: Int = -1
	private var loadingScore: Int = -1 {
		didSet {
			scoreLabel.text = "\(loadingScore)"
		}
	}
	private var isNewBest = false
	private var isNewMedal = false
	
	// Nodes
	private lazy var gameOverText = childNode(withName: "GameOver") as! SKSpriteNode
	private lazy var scorePanel = childNode(withName: "ScorePanel") as! SKSpriteNode
	
	private lazy var scoreLabel = scorePanel.childNode(withName: "Score") as! SKLabelNode2
	private lazy var bestScoreLabel = scorePanel.childNode(withName: "BestScore") as! SKLabelNode2
	private lazy var newLabel = scorePanel.childNode(withName: "New") as! SKSpriteNode
	private lazy var medal = scorePanel.childNode(withName: "Medal") as! SKSpriteNode
	private var twinkles = SKNode()
	
	private lazy var buttons = childNode(withName: "Buttons")!
	private lazy var btnNewGame = buttons.childNode(withName: ButtonIdentifier.play.rawValue) as! ButtonNode
	private lazy var btnLeaderboards = buttons.childNode(withName: ButtonIdentifier.leaderboards.rawValue) as! ButtonNode
	private lazy var btnHome = buttons.childNode(withName: ButtonIdentifier.home.rawValue) as! ButtonNode
	private lazy var btnShare = buttons.childNode(withName: ButtonIdentifier.share.rawValue) as! ButtonNode
	
	private let swooshSound = SKAudioNode(fileNamed: "sfx_swooshing")
	
	
	override func sceneDidLoad(_ tag: String) {
		super.sceneDidLoad(tag)
		
		buttons.children.forEach {
			let b = $0 as! ButtonNode
			b.imgNode!.texture!.filteringMode = .nearest
			b.isUserInteractionEnabled = false
		}
		
		gameOverText.texture!.filteringMode = .nearest
		scorePanel.texture!.filteringMode = .nearest
		
		scoreLabel.zPosition = 1
		scoreLabel.fontTextureAtlas = SKTextureAtlas(named: "number_score")
		scoreLabel.fontMap = { atlas, c in
			return atlas.textureNamed("number_score_0\(c)")
		}
		scoreLabel.horizontalAlignmentMode = .right
		
		bestScoreLabel.zPosition = 1
		bestScoreLabel.fontTextureAtlas = SKTextureAtlas(named: "number_score")
		bestScoreLabel.fontMap = { atlas, c in
			return atlas.textureNamed("number_score_0\(c)")
		}
		bestScoreLabel.horizontalAlignmentMode = .right
		
		newLabel.texture!.filteringMode = .nearest
		newLabel.zPosition = 1
		
		medal.zPosition = 1
		
		let twinkleTextureAtlas = SKTextureAtlas(named: "blink")
		let twinkle = SKSpriteNode(texture: twinkleTextureAtlas.textureNamed(twinkleTextureAtlas.textureNames.first!))
		let blinking = SKAction.animate(with: twinkleTextureAtlas.textureNames.map {
			let t = twinkleTextureAtlas.textureNamed($0)
			t.filteringMode = .nearest
			return t
		}, timePerFrame: 0.16)
		let blinkingForever = SKAction.repeatForever(blinking)
		
		for _ in 0 ... 7 {
			let t = twinkle.copy() as! SKSpriteNode
			t.run(SKAction.sequence([
				SKAction.wait(forDuration: TimeInterval(arc4random_uniform(20)) / 40),
				blinkingForever
			]), withKey: "blinking")
			twinkles.addChild(t)
		}
		
		twinkles.zPosition = 1
		medal.addChild(twinkles)
		
		addChild(swooshSound)
		swooshSound.autoplayLooped = false
	}
	
	func update(_ tag: String, levelScene: GameScene) {
		self.gameNo = levelScene.gameNo
		self.score = levelScene.score
		
		let best = UserDefaults.standard.integer(forKey: CommonConfig.Keys.bestScore)
		newBestScore = max(best, self.score)
		if newBestScore != best { UserDefaults.standard.set(newBestScore, forKey: CommonConfig.Keys.bestScore) }
		
		isNewBest = best < newBestScore
		bestScoreLabel.text = "\(best)"
		
		let achievement: String?
		
		if score >= 100 {
			achievement = "medal_gold"
			medal.texture = SKTexture(imageNamed: "medal_gold")
			isNewMedal = best < 100
		} else if score >= 40 {
			achievement = "medal_silver"
			medal.texture = SKTexture(imageNamed: "medal_silver")
			isNewMedal = best < 40
		} else if score >= 20 {
			achievement = "medal_bronze"
			medal.texture = SKTexture(imageNamed: "medal_bronze")
			isNewMedal = best < 20
		} else if score >= 10 {
			achievement = "medal_aluminum"
			medal.texture = SKTexture(imageNamed: "medal_aluminum")
			isNewMedal = best < 10
		} else {
			achievement = nil
			medal.texture = nil
			isNewMedal = false
		}
		medal.texture?.filteringMode = .nearest
		
		if achievement != nil { GameCenterHelper.reportAchievement(TAG, achievement!) }
	}
	
	override func willMove(_ tag: String, to scene: SKScene) {
		super.willMove(tag, to: scene)
		
		let gameOverTextureSize = gameOverText.texture!.size()
		let gameOverScale = min(scene.frame.height * 0.12 / gameOverTextureSize.height, scene.frame.width * 0.8 / gameOverTextureSize.width)
		gameOverText.size = CGSize(width: gameOverTextureSize.width * gameOverScale, height: gameOverTextureSize.height * gameOverScale)
		gameOverText.position.y = scene.frame.maxY + gameOverText.size.height / 2
		
		let panelTextureSize = scorePanel.texture!.size()
		let panelScale = min(scene.frame.height * 0.3 / panelTextureSize.height, scene.frame.width * 0.9 / panelTextureSize.width)
		scorePanel.size = CGSize(width: panelTextureSize.width * panelScale, height: panelTextureSize.height * panelScale)
		scorePanel.position.y = scene.frame.maxY + scorePanel.size.height / 2
		
		scoreLabel.fontSize = scorePanel.size.height * 0.13
		scoreLabel.textSpace = scoreLabel.fontSize * 0.1
		scoreLabel.position = CGPoint(x: scorePanel.size.width * 0.38, y: scorePanel.size.height * 0.14)
		bestScoreLabel.fontSize = scorePanel.size.height * 0.13
		bestScoreLabel.textSpace = bestScoreLabel.fontSize * 0.1
		bestScoreLabel.position = CGPoint(x: scorePanel.size.width * 0.38, y: -scorePanel.size.height * 0.21)
		
		loadingScore = 0
		
		let newLabelHeight = scorePanel.size.height * 0.1
		let newLabelTextureSize = newLabel.texture!.size()
		newLabel.size = CGSize(width: newLabelHeight * newLabelTextureSize.width / newLabelTextureSize.height, height: newLabelHeight)
		newLabel.position = CGPoint(x: scorePanel.size.width * 0.125, y: -scorePanel.size.height * 0.036)
		newLabel.isHidden = true
		
		if medal.texture != nil {
			let medalHeight = scorePanel.size.height * 0.348
			let medalTextureSize = medal.texture!.size()
			medal.size = CGSize(width: medalHeight * medalTextureSize.width / medalTextureSize.height, height: medalHeight)
			medal.position = CGPoint(x: -scorePanel.size.width * 0.273, y: -scorePanel.size.height * 0.028)
		}
		medal.isHidden = true
		
		let medalRadius = medal.size.height * 0.5
		let size = medal.size.width * 0.15
		twinkles.children.forEach {
			($0 as! SKSpriteNode).size = CGSize(width: size, height: size)
			
			let r = medalRadius * sqrt(CGFloat(arc4random()) / CGFloat(UInt32.max))
			let theta = (CGFloat(arc4random()) / CGFloat(UInt32.max)) * 2 * Double.pi
			$0.position = CGPoint(x: r * cos(theta), y: r * sin(theta))
		}
		twinkles.isHidden = true
		
		buttons.children.forEach {
			let b = $0 as! ButtonNode
			let btnTextureSize = b.imgNode!.texture!.size()
			let scale = min(scene.frame.height * 0.12 / btnTextureSize.height, scene.frame.width * 0.3 / btnTextureSize.width)
			b.imgNode!.size = CGSize(width: btnTextureSize.width * scale, height: btnTextureSize.height * scale)
			b.size = CGSize(width: b.imgNode!.size.width + 3, height: b.imgNode!.size.height + 3)
		}
		btnNewGame.position = CGPoint(x: -scene.frame.width * 0.22, y: 0)
		btnLeaderboards.position = CGPoint(x: scene.frame.width * 0.22, y: 0)
		btnHome.position = CGPoint(x: -scene.frame.width * 0.22, y: btnNewGame.frame.minY - btnHome.size.height)
		btnShare.position = CGPoint(x: scene.frame.width * 0.22, y: btnHome.position.y)
		
		let buttonsHeight = btnNewGame.frame.height
		buttons.position.y = scene.frame.minY - buttonsHeight / 2
	}
	
	override func didMove(_ tag: String, to scene: SKScene) {
		super.didMove(tag, to: scene)
		
		gameOverText.run(SKAction.move(to: CGPoint(x: 0, y: scene.frame.height * 0.25), duration: 0.15)) { [weak self] in
			self!.scorePanel.run(SKAction.move(to: CGPoint(x: 0, y: scene.frame.height * 0), duration: 0.3)) { [weak self] in
				self!.runScore()
				self!.buttons.run(SKAction.move(to: CGPoint(x: 0, y: -scene.frame.height * 0.22), duration: 0.15)) { [weak self] in
					self!.didShow("")
				}
			}
		}
		(self.scene as! BaseSKScene).playSound(self.swooshSound)
	}
	
	private func runScore() {
		var sequence: [SKAction] = [SKAction.wait(forDuration: 0.5)]
		for s in 0 ... score {
			sequence += [
				SKAction.run { [weak self] in self!.loadingScore = s },
				SKAction.wait(forDuration: 0.1)
			]
		}
		
		run(SKAction.sequence(sequence)) { [weak self] in
			if self!.medal.texture != nil {
				self!.medal.isHidden = false
			}
			self!.newLabel.isHidden = !self!.isNewBest
			self!.twinkles.isHidden = !self!.isNewMedal
			self!.bestScoreLabel.text = "\(self!.newBestScore)"
		}
	}
	
	private func didShow(_ tag: String) {
		buttons.children.forEach {
			$0.isUserInteractionEnabled = true
		}
		
		_ = (self.scene!.view!.viewController as! GameViewController).showAdInterstitial("\(self.TAG)|didShow|\(tag)", gameNo: self.gameNo)
	}
}
