//
//  Created by Thang Nguyen on 12/28/21.
//

import SpriteKit
import GameplayKit

import XLibrary

class HomeScene: BaseScene {
	
	private let TAG = "🏠"
	
	private var sceneLoaded = false
	
	// Calculation

	// Nodes	
	private lazy var root = childNode(withName: "root")!
	
	private lazy var banner = root.childNode(withName: "Banner")!
	private lazy var title = banner.childNode(withName: "title") as! SKSpriteNode
	private lazy var mainCharacter = banner.childNode(withName: "bird") as! SKSpriteNode
	
	private lazy var copyright = root.childNode(withName: "copyright") as! SKLabelNode
	
	private lazy var buttons = root.childNode(withName: "Buttons")!
	private lazy var btnPlay = buttons.childNode(withName: ButtonIdentifier.play.rawValue) as! ButtonNode
	private lazy var btnLeaderboards = buttons.childNode(withName: ButtonIdentifier.leaderboards.rawValue) as! ButtonNode
	private lazy var btnRate = buttons.childNode(withName: ButtonIdentifier.rate.rawValue) as! ButtonNode
	private lazy var btnAds = buttons.childNode(withName: ButtonIdentifier.ads.rawValue) as! ButtonNode
	
	
	override func sceneDidLoad() {
		super.sceneDidLoad()
		
		scaleMode = .resizeFill
		
		initObjects("sceneDidLoad")
	}
	
	override func didMove(to view: SKView) {
		// NSLog("--  \(TAG) | didMove to view | \(size)")
		super.didMove(to: view)
		
		resizeScene("didMove")
		
		sceneLoaded = true
		
		NotificationCenter.default.post(name: .homeEntered, object: nil)
	}
	
	override func didChangeSize(_ oldSize: CGSize) {
		super.didChangeSize(oldSize)
		
		if sceneLoaded { resizeScene("didChangeSize") }
	}
	
	private func initObjects(_ tag: String) {
		banner.zPosition = GameLayer.mainCharacter.rawValue
		
		let mainCharTextureAtlas = SKTextureAtlas(named: "bird0")
		mainCharacter.texture = mainCharTextureAtlas.textureNamed(mainCharTextureAtlas.textureNames.first!)
		let anim = SKAction.animate(with: mainCharTextureAtlas.textureNames.map {
			let t = mainCharTextureAtlas.textureNamed($0)
			t.filteringMode = .nearest
			return t
		}, timePerFrame: 0.08)
		let flap = SKAction.repeatForever(anim)
		mainCharacter.run(flap, withKey: "flap")
		
		title.texture!.filteringMode = .nearest
		
		copyright.zPosition = GameLayer.navigation.rawValue
		
		buttons.zPosition = GameLayer.navigation.rawValue
		buttons.children.forEach {
			let b = $0 as! ButtonNode
			b.imgNode!.texture!.filteringMode = .nearest
		}
	}
	
	private func resizeScene(_ tag: String) {
		NSLog("--  \(TAG) | resizeScene [\(tag)]: \(frame)")
		
		// Bird
		let mainCharTextureSize = mainCharacter.texture!.size()
		mainCharacter.setScale(min(frame.width * 0.12 / mainCharTextureSize.width, frame.height * 0.06 / mainCharTextureSize.height))
		
		title.setScale(mainCharacter.xScale)
		title.position.x = -title.size.width * 0.17
		mainCharacter.position.x = title.size.width * 0.57
		
		banner.position.y = frame.height * 0.27
		
		let hop = SKAction.moveBy(x: 0, y: mainCharacter.size.height * 0.5, duration: 0.3)
		banner.run(SKAction.repeatForever(SKAction.sequence([hop, hop.reversed()])), withKey: "hop")
		
		let MAIN_CHARACTER_WIDTH = mainCharacter.size.width
		
		let VELOCITY = MAIN_CHARACTER_WIDTH * 4
		let BG_VELOCITY = MAIN_CHARACTER_WIDTH * 0.2
		
		// background
		let background = root.childNode(withName: "background")!
		background.removeAllChildren()
		background.zPosition = GameLayer.ObjectLayer.sky.rawValue
		
		let bgTexture = SKTexture(imageNamed: "bg_day")
		bgTexture.filteringMode = .nearest
		
		let bgTextureSize = bgTexture.size()
		let bgWidth = max(frame.width, frame.height * bgTextureSize.width / bgTextureSize.height)
		let bgHeight = max(frame.height, frame.width * bgTextureSize.height / bgTextureSize.width)
		
		let moveBg = SKAction.moveBy(x: -bgWidth, y: 0, duration: TimeInterval(bgWidth / BG_VELOCITY))
		let resetBg = SKAction.moveBy(x: bgWidth, y: 0, duration: 0.0)
		let moveBgsForever = SKAction.repeatForever(SKAction.sequence([moveBg, resetBg]))
		
		for i in 0 ..< 2 + Int(self.frame.width / bgWidth) {
			let node = SKSpriteNode(texture: bgTexture)
			
			node.size = CGSize(width: bgWidth + 1, height: bgHeight)
			node.position = CGPoint(x: CGFloat(i) * bgWidth, y: 0)
			
			node.run(moveBgsForever)
			
			background.addChild(node)
		}
		
		// ground
		let grounds = root.childNode(withName: "ground")!
		grounds.zPosition = GameLayer.ObjectLayer.ground.rawValue
		grounds.removeAllChildren()
		
		let groundTexture = SKTexture(imageNamed: "land")
		groundTexture.filteringMode = .nearest
		
		let groundTextureSize = groundTexture.size()
		let groundWidth = frame.width
		let groundHeight = frame.width * groundTextureSize.height / groundTextureSize.width
		let GROUND_HEIGHT_ON_DISPLAY = min(groundHeight, frame.height * 0.2)
		
		let moveGround = SKAction.moveBy(x: -groundWidth, y: 0, duration: TimeInterval(groundWidth / VELOCITY))
		let resetGround = SKAction.moveBy(x: groundWidth, y: 0, duration: 0.0)
		let moveGroundsForever = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))
		
		for i in 0 ... 1 + Int(self.frame.width / groundWidth) {
			let ground = SKSpriteNode(texture: groundTexture)
			ground.name = "ground"
			ground.size = CGSize(width: groundWidth + 1, height: groundHeight)
			ground.position = CGPoint( x: CGFloat(i) * groundWidth, y: -frame.height/2 - groundHeight/2 + GROUND_HEIGHT_ON_DISPLAY )
			
			ground.run(moveGroundsForever)
			
			grounds.addChild(ground)
		}
		
		copyright.fontSize = min(frame.height * 0.025, frame.width * 0.04)
		copyright.position.y = grounds.children.first!.frame.maxY - grounds.children.first!.frame.height * 0.35
		
		[btnPlay, btnLeaderboards].forEach { b in
			let btnTextureSize = b.imgNode!.texture!.size()
			let scale = min(frame.height * 0.12 / btnTextureSize.height, frame.width * 0.3 / btnTextureSize.width)
			b.imgNode!.setScale(scale)
		}
		[btnRate, btnAds].forEach { b in
			let scale = btnPlay.imgNode!.xScale * 1
			b.imgNode!.setScale(scale)
		}
		buttons.children.forEach {
			let b = $0 as! ButtonNode
			b.size = CGSize(width: b.imgNode!.size.width + 3, height: b.imgNode!.size.height + 3)
		}
		btnPlay.position = CGPoint(x: -frame.width * 0.22, y: 0)
		btnLeaderboards.position = CGPoint(x: frame.width * 0.22, y: 0)
		btnRate.position = CGPoint(x: 0, y: btnPlay.size.height * 0.9)
		btnAds.position = CGPoint(x: 0, y: -btnPlay.size.height * 0.9)
		
		buttons.position.y = -frame.height * 0.15
	}
}
