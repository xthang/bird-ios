//
//  Created by Thang Nguyen on 11/21/21.
//

import UIKit

import XLibrary

class DEV: PopupView {
	
	private let TAG = "\(DEV.self)"
	
	private var keyboardConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var levelTextField: UITextField!
	
	@IBOutlet weak var logo: UIView!
	
	@IBOutlet private weak var circle: UIImageView!
	private lazy var circleImage = circle.image!
	@IBOutlet private weak var circleAspectTextField: UITextField!
	
	
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		animationStyle = .fade
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		let stretchedImg = resizeImageToFit("awakeFromNib", circleImage, size: circle.frame.size, aspect: Float(circle.frame.width / circle.frame.height))
		circle.image = stretchedImg
		
		keyboardConstraint = NSLayoutConstraint(item: contentView!,
															 attribute: .bottom,
															 relatedBy: .lessThanOrEqual,
															 toItem: self,
															 attribute: .bottom,
															 multiplier: 1,
															 constant: 0)
		keyboardConstraint.isActive = false
	}
	
	// MARK: - Lifecycle
	
	override func didMoveToSuperview() {
		super.didMoveToSuperview()
		
		if superview != nil {
			NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShowNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
			NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHideNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
		} else {
			NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
			NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
		}
	}
	
	@objc private func keyboardWillShowNotification(_ notification: NSNotification) {
		let userInfo = notification.userInfo!
		
		let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
		let keyboardFrame = keyboardSize.cgRectValue
		if !keyboardConstraint.isActive {
			keyboardConstraint.constant = -keyboardFrame.height - frame.height / 20
			keyboardConstraint.isActive = true
		}
	}
	
	@objc private func keyboardWillHideNotification(notification: NSNotification) {
		if keyboardConstraint.isActive {
			keyboardConstraint.isActive = false
		}
	}
	
	@IBAction func hideDevBtn(_ sender: UIButton) {
		print("--  \(TAG) | hideDevBtn ...")
		
		(viewController as? GameViewController)?.devBtn.isHidden = true
	}
	
	@IBAction func reset(_ sender: UIButton) {
		print("--  \(TAG) | reset ...")
		
		UserDefaults.standard.setValue(nil, forKey: CommonConfig.Keys.appDataVersion)
		UserDefaults.standard.setValue(nil, forKey: CommonConfig.Keys.welcomeVersion)
		
		UserDefaults.standard.setValue(nil, forKey: CommonConfig.Keys.gamesCount)
		UserDefaults.standard.setValue(nil, forKey: CommonConfig.Keys.gameLevel)
		UserDefaults.standard.setValue(nil, forKey: CommonConfig.Keys.bestScore)
		
		UserDefaults.standard.setValue(nil, forKey: CommonConfig.Keys.coinCount)
		UserDefaults.standard.setValue(nil, forKey: CommonConfig.Keys.purchased)
		
		Snackbar.s("RESET DONE")
	}
	
	@IBAction func resetWelcome(_ sender: UIButton) {
		print("--  \(TAG) | resetWelcome ...")
		
		UserDefaults.standard.setValue(nil, forKey: CommonConfig.Keys.welcomeBannerVersion)
		
		Snackbar.s("resetWelcome DONE")
	}
	
	@IBAction func setAspect(_ sender: UIButton) {
		print("--  \(TAG) | setAspect ...")
		
		guard let aspect = circleAspectTextField.text, !aspect.isEmpty else {
			NSLog("!-  \(TAG) | setAspect: empty value")
			Snackbar.w("Set aspect: empty value")
			return
		}
		let aspectComponents = aspect.components(separatedBy: ":")
		guard aspectComponents.count == 2, let first = Float(aspectComponents[0]), let second = Float(aspectComponents[1]) else {
			NSLog("!-  \(TAG) | setAspect: invalid value: \(aspectComponents)")
			Snackbar.w("Set aspect: invalid value: \(aspectComponents)")
			return
		}
		
		circle.removeConstraint(circle.constraints.first(where: { $0.identifier == "aspect" })!)
		let aspectConstraint = NSLayoutConstraint(item: circle!,
																attribute: .width,
																relatedBy: .equal,
																toItem: circle,
																attribute: .height,
																multiplier: CGFloat(first / second),
																constant: 0)
		aspectConstraint.identifier = "aspect"
		aspectConstraint.isActive = true
		
		let stretchedImg = resizeImageToFit("setAspect", circleImage, size: circle.frame.size, aspect: first/second)
		circle.image = stretchedImg
		circle.sizeToFit()
		
		Snackbar.s("Set aspect [\(aspect)]: DONE - \(circleImage.size) -> \(stretchedImg.size)")
	}
	
	private func resizeImageToFit(_ tag: String, _ originalImage: UIImage, size: CGSize, aspect: Float) -> UIImage {
		let scale = min(size.width / originalImage.size.width, size.height / originalImage.size.height)
		let resizedImage = originalImage.resized(to: CGSize(width: originalImage.size.width * scale, height: originalImage.size.height * scale))
		
		let horizontalInset = aspect > 1 ? resizedImage.size.width * 0.5 : 0
		let verticalInset = aspect > 1 ? 0 : resizedImage.size.height * 0.5
		let stretchedImg = resizedImage.resizableImage(
			withCapInsets: UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset),
			resizingMode: .stretch)
		
		print("--  resizeImageToFit [\(tag)]: \(originalImage.size) -> \(resizedImage.size) ~ \(stretchedImg.size)")
		
		return stretchedImg
	}
	
	@IBAction func saveLogo(_ sender: UIButton) {
		let l: UIView
		if sender.tag == 2 {
			l = logo
		} else {
			l = logo
		}
		
		let png = l.asPngData()
		
		let r = l.cornerRadiusRatio
		l.cornerRadiusRatio = 0
		let png2 = l.asPngData()
		l.cornerRadiusRatio = r
		
		// UIImageWriteToSavedPhotosAlbum(logo.asImage(), self, #selector(saveCompleted(_:didFinishSavingWithError:contextInfo:)), nil)
		
		//let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		//if let url = urls.first?.appendingPathComponent("logo.png") {
		//	do {
		//		try logo.asPngData().write(to: url)
		//		NSLog("--  About | saveLogo ok: \(url)")
		//		Snackbar.s("Logo is saved to: \(url)")
		//	} catch {
		//		NSLog("--  About | saveLogo: \(url) | error: \(error)")
		//		Snackbar.e("Save logo: \(error)")
		//	}
		//}
		
		let activityViewController = UIActivityViewController(activityItems: [png, png2], applicationActivities: nil)
		activityViewController.popoverPresentationController?.sourceView = sender
		viewController!.present(activityViewController, animated: true, completion: nil)
	}
	
	@IBAction func saveImage(_ sender: UIButton) {
		let l: UIImageView
		if sender.tag == 2 {
			l = circle
		} else {
			l = circle
		}
		
		let img = l.asPngData()
		
		let activityViewController = UIActivityViewController(activityItems: [img], applicationActivities: nil)
		activityViewController.popoverPresentationController?.sourceView = sender
		viewController!.present(activityViewController, animated: true, completion: nil)
	}
	
	@objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
		if let error = error {
			let alert = PopupAlert.initiate(title: "Save error", message: error.localizedDescription)
			addSubview(alert)
		} else {
			Snackbar.s("Your image has been saved to your photos")
		}
	}
}
