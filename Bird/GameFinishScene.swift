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
	private var loadingScore: Int = -1 {
		didSet {
			scoreLabel.text = "\(loadingScore)"
		}
	}
	
	// Nodes
	private lazy var gameOverText = childNode(withName: "GameOver") as! SKSpriteNode
	private lazy var scorePanel = childNode(withName: "ScorePanel") as! SKSpriteNode
	
	private lazy var scoreLabel = scorePanel.childNode(withName: "Score") as! SKLabelNode2
	private lazy var bestScoreLabel = scorePanel.childNode(withName: "BestScore") as! SKLabelNode2
	private lazy var newLabel = scorePanel.childNode(withName: "New") as! SKSpriteNode
	private lazy var medal = scorePanel.childNode(withName: "Medal") as! SKSpriteNode
	
	private lazy var buttons = childNode(withName: "Buttons")!
	private lazy var btnNewGame = buttons.childNode(withName: "Play") as! ButtonNode
	private lazy var btnHome = buttons.childNode(withName: "Home") as! ButtonNode
	private lazy var btnShare = buttons.childNode(withName: "Share") as! ButtonNode
	
	
	override func sceneDidLoad(_ tag: String) {
		super.sceneDidLoad(tag)
		
		[btnNewGame, btnHome, btnShare].forEach {
			$0.imgNode!.texture!.filteringMode = .nearest
			$0.isUserInteractionEnabled = false
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
		
		medal.zPosition = 1
	}
	
	func update(_ tag: String, levelScene: GameScene) {
		self.gameNo = levelScene.gameNo
		self.score = levelScene.score
		
		medal.texture = SKTexture(imageNamed: "medal_gold")
		medal.texture!.filteringMode = .nearest
		
		let best = UserDefaults.standard.integer(forKey: CommonConfig.Keys.bestScore)
		let newBest = max(best, self.score)
		UserDefaults.standard.set(newBest, forKey: CommonConfig.Keys.bestScore)
		//	self!.newLabel.isHidden = best >= score
		self.bestScoreLabel.text = "\(newBest)"
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
		scoreLabel.position = CGPoint(x: scorePanel.size.width * 0.38, y: scorePanel.size.height * 0.14)
		bestScoreLabel.fontSize = scorePanel.size.height * 0.13
		bestScoreLabel.position = CGPoint(x: scorePanel.size.width * 0.38, y: -scorePanel.size.height * 0.21)
		
		loadingScore = 0
		
		let newLabelHeight = scorePanel.size.height * 0.1
		let newLabelTextureSize = newLabel.texture!.size()
		newLabel.size = CGSize(width: newLabelHeight * newLabelTextureSize.width / newLabelTextureSize.height, height: newLabelHeight)
		newLabel.position = CGPoint(x: scorePanel.size.width * 0.125, y: -scorePanel.size.height * 0.036)
		newLabel.isHidden = false
		
		let medalHeight = scorePanel.size.height * 0.348
		let medalTextureSize = medal.texture!.size()
		medal.size = CGSize(width: medalHeight * medalTextureSize.width / medalTextureSize.height, height: medalHeight)
		medal.position = CGPoint(x: -scorePanel.size.width * 0.273, y: -scorePanel.size.height * 0.028)
		medal.isHidden = true
		
		[btnNewGame, btnHome, btnShare].forEach {
			let btnTextureSize = $0.imgNode!.texture!.size()
			let scale = min(scene.frame.height * 0.1 / btnTextureSize.height, scene.frame.width * 0.25 / btnTextureSize.width)
			$0.imgNode!.size = CGSize(width: btnTextureSize.width * scale, height: btnTextureSize.height * scale)
			$0.size = CGSize(width: $0.imgNode!.size.width + 3, height: $0.imgNode!.size.height + 3)
		}
		btnNewGame.position.x = -scene.frame.width * 0.3
		btnShare.position.x = scene.frame.width * 0.3
		
		let buttonsHeight = btnNewGame.frame.height
		buttons.position.y = scene.frame.minY - buttonsHeight / 2
	}
	
	override func didMove(_ tag: String, to scene: SKScene) {
		super.didMove(tag, to: scene)
		
		gameOverText.run(SKAction.move(to: CGPoint(x: 0, y: scene.frame.height * 0.25), duration: 0.3)) { [weak self] in
			self!.scorePanel.run(SKAction.move(to: CGPoint(x: 0, y: scene.frame.height * 0), duration: 0.4)) { [weak self] in
				self!.buttons.run(SKAction.move(to: CGPoint(x: 0, y: -scene.frame.height * 0.25), duration: 0.3)) { [weak self] in
					self!.didShow("")
				}
			}
		}
	}
	
	private func didShow(_ tag: String) {
		print("--  \(TAG) | didShow [\(tag)]")
		
		var sequence: [SKAction] = [SKAction.wait(forDuration: 0.5)]
		for s in 0 ... score {
			sequence += [
				SKAction.run { [weak self] in self!.loadingScore = s },
				SKAction.wait(forDuration: 0.1)
			]
		}
		
		run(SKAction.sequence(sequence)) { [weak self] in
			
			self!.medal.isHidden = false
			
			self!.btnNewGame.isUserInteractionEnabled = true
			self!.btnHome.isUserInteractionEnabled = true
			self!.btnShare.isUserInteractionEnabled = true
			
			_ = (self!.scene!.view!.viewController as! GameViewController).showAdInterstitial("\(self!.TAG)|didShow|\(tag)", gameNo: self!.gameNo)
		}
	}
}
