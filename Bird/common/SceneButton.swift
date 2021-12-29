//
//  Created by Thang Nguyen on 10/15/21.
//

import UIKit

import XLibrary

class SceneButton: BaseSceneButton {
	
	private let TAG = "\(SceneButton.self)"
	
	required init() {
		super.init()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		let theme = Theme.current!
		
		if let c = theme.settings.buttonHighlightedBackgroundColor { highlightedColor = c }
		if let c = theme.settings.buttonDisabledBackgroundColor { disabledColor = c }
		
		if let c = theme.settings.buttonHighlightedTextColor { setTitleColor(c, for: .highlighted) }
		if let c = theme.settings.buttonDisabledTextColor { setTitleColor(c, for: .disabled) }
		
		if let r = theme.settings.buttonCornerRadiusRatio { cornerRadiusRatio = r }
		
		if let r = theme.settings.buttonShadowRadius { shadowRadius = r }
		if let c = theme.settings.buttonShadowColor { shadowColor = c }
	}
}
