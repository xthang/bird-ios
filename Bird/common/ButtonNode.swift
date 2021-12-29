/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 `ButtonNode` is a custom `SKSpriteNode` that provides button-like behavior in a SpriteKit scene. It is supported by `ButtonNodeResponderType` (a protocol for classes that can respond to button presses) and `ButtonIdentifier` (an enumeration that defines all of the kinds of buttons that are supported in the game).
 */

import SpriteKit

import XLibrary

/// A custom sprite node that represents a press able and selectable button in a scene.
class ButtonNode: BaseButtonNode {
	
	private let TAG = "\(ButtonNode.self)"
	
	// MARK: Properties
	
	// MARK: Functions
	
	// MARK: Responder
	
#if os(iOS)
	open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		
		isFocused = true
	}
	
	open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		
		isFocused = false
	}
	
	open override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
		super.touchesCancelled(touches!, with: event)
		
		isFocused = false
	}
	
#elseif os(OSX)
	override func mouseDown(with event: NSEvent) {
		super.mouseDown(with: event)
		
		isFocused = true
	}
	
	override func mouseUp(with event: NSEvent) {
		super.mouseUp(with: event)
		
		isFocused = false
	}
#endif
}
