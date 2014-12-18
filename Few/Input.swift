//
//  Input.swift
//  Few
//
//  Created by Josh Abernathy on 9/4/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

private class InputDelegate: NSObject, NSTextFieldDelegate {
	var action: (NSTextField -> ())?

	override func controlTextDidChange(notification: NSNotification) {
		let field = notification.object as NSTextField
		action?(field)
	}
}

public class Input: Element {
	public let text: String?
	private let initialText: String?
	private let placeholder: String?
	private let enabled: Bool
	private let action: String -> ()

	private let inputDelegate = InputDelegate()

	public convenience init(text: String?, fn: String -> ()) {
		self.init(text: text, initialText: nil, placeholder: nil, enabled: true, action: fn)
	}

	public convenience init(initialText: String?, placeholder: String?, fn: String -> ()) {
		self.init(text: nil, initialText: initialText, placeholder: placeholder, enabled: true, action: fn)
	}

	public init(text: String?, initialText: String?, placeholder: String?, enabled: Bool, action: String -> ()) {
		self.text = text
		self.initialText = initialText
		self.placeholder = placeholder
		self.action = action
		self.enabled = enabled
		super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 23))
		
		self.inputDelegate.action = { [unowned self] field in
			self.action(field.stringValue)
		}
	}

	public required init(copy: Element, frame: CGRect, hidden: Bool, alpha: CGFloat, key: String?) {
		let input = copy as Input
		text = input.text
		initialText = input.initialText
		placeholder = input.placeholder
		enabled = input.enabled
		action = input.action
		super.init(copy: copy, frame: frame, hidden: hidden, alpha: alpha, key: key)

		self.inputDelegate.action = { [unowned self] field in
			self.action(field.stringValue)
		}
	}

	// MARK: Element
	
	public override func applyDiff(view: ViewType, other: Element) {
		let otherInput = other as Input
		let textField = view as NSTextField

		textField.delegate = inputDelegate

		let cell = textField.cell() as? NSTextFieldCell
		cell?.placeholderString = placeholder ?? ""

		if let text = text {
			if text != textField.stringValue {
				textField.stringValue = text
			}
		}

		if enabled != textField.enabled {
			textField.enabled = enabled
		}

		super.applyDiff(view, other: other)
	}
	
	public override func realize() -> ViewType? {
		let field = NSTextField(frame: frame)
		field.editable = true
		field.stringValue = text ?? initialText ?? ""
		field.delegate = inputDelegate
		field.enabled = enabled

		let cell = field.cell() as? NSTextFieldCell
		cell?.placeholderString = placeholder ?? ""
		return field
	}
}
