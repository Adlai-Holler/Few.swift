//
//  QuickLook.swift
//  Few
//
//  Created by Josh Abernathy on 12/20/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

extension Element {
	public func debugQuickLookObject() -> AnyObject? {
		let realizedElement = realizeElementRecursively(self)
		return realizedElement.view
	}

	public var ql: NSView {
		return debugQuickLookObject()! as NSView
	}
}
