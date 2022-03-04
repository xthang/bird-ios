//
//  Created by Thang Nguyen on 10/15/21.
//

import SpriteKit

import XLibrary

class BaseScene: BaseSKScene, ButtonResponder {
	
	private let TAG = "BS"
	
	open func buttonTriggered(_ button: IButton) {
		
		switch button.buttonIdentifier! {
			case .close, .cancel:
				break
			case .home:
				overlays.forEach { $0.removeFromSuperview() }	// TODO
				
				let scene = HomeScene(fileNamed: "HomeScene")!
				view?.presentScene("\(TAG)|buttonTriggered", scene, transition: .doorsOpenVertical(withDuration: 0.5))
			case .play, .replay:
				let scene = GameScene(fileNamed: "GameScene")!
				view!.presentScene("\(TAG)|buttonTriggered", scene, transition: .doorsOpenHorizontal(withDuration: 0.5))
			case .pause:
				pause("buttonTriggered")
			case .resume:
				resume("buttonTriggered")
			case .share:
				if let img = view?.texture(from: self)?.cgImage() {
					let text = String(format: NSLocalizedString("I am playing %@! Let's play with me!", comment: ""), (Bundle.main.infoDictionary!["CFBundleDisplayName"] ?? Bundle.main.infoDictionary!["CFBundleName"]) as! CVarArg)
					
					let rect: CGRect?
					if let b = button as? SKNode {
						let absPoint = b.convert(CGPoint.zero, to: self)
						let absPointInView = CGPoint(x: absPoint.x + view!.frame.width / 2, y: -absPoint.y + view!.frame.height / 2)
						// print("--  \(absPoint) | \(absPointInView)")
						rect = CGRect(origin: absPointInView, size: b.frame.size)
					} else { rect = nil }
					
					Helper.share(TAG, button as? UIView ?? view!, rect, viewController: nil, text: text, image: UIImage(cgImage: img))
				}
			case .DEV, .about, .back, .hint, .settings, .sound, .gameCenter, .leaderboards, .achievements, .rate, .ads:
				fatalError("Unsupported ButtonNode type `\(button.buttonIdentifier!)` in Scene.")
		}
	}
}
