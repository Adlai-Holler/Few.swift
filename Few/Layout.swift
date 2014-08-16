//
//  Layout.swift
//  Few
//
//  Created by Josh Abernathy on 8/11/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

public func absolute<S>(element: Element<S>, frame: CGRect) -> Layout<S> {
	return Layout(element: element, fn: const(frame))
}

public func absolute<S>(element: Element<S>, size: CGSize) -> Layout<S> {
	return Layout(element: element) { element in
		CGRect(origin: element.frame.origin, size: size)
	}
}

public func absolute<S>(element: Element<S>, origin: CGPoint) -> Layout<S> {
	return Layout(element: element) { element in
		CGRect(origin: origin, size: element.frame.size)
	}
}

public func absolute<S>(origin: CGPoint)(element: Element<S>) -> Layout<S> {
	return absolute(element, origin)
}

public func sizeToFit<S>(element: Element<S>) -> Layout<S> {
	return Layout(element: element) { element in
		let size = element.getIntrinsicSize()
		return CGRect(origin: element.frame.origin, size: size)
	}
}

public func offset<S>(element: Element<S>, dx: CGFloat, dy: CGFloat) -> Layout<S> {
	return Layout(element: element) { element in
		CGRectOffset(element.frame, dx, dy)
	}
}

public func offset<S>(dx: CGFloat, dy: CGFloat)(element: Element<S>) -> Layout<S> {
	return offset(element, dx, dy)
}

public class Layout<S: Equatable>: Element<S> {
	private var element: Element<S>

	private var layoutFn: Element<S> -> CGRect
	
	private weak var component: Component<S>?
	private var parentView: NSView?
	
//	public override var frame: CGRect {
//		set {
//			element.frame = CGRectOffset(element.frame, newValue.origin.x, newValue.origin.y)
//		}
//		
//		get {
//			return element.frame
//		}
//	}

	public init(element: Element<S>, fn: Element<S> -> CGRect) {
		self.element = element
		self.layoutFn = fn
	}
	
	public override func applyLayout(fn: CGRect -> CGRect) {
		element.frame = fn(element.frame)
	}

	private func layoutElements() {
		// TODO: use applyLayout
		let newFrame = layoutFn(element)
		if newFrame != element.frame {
			element.frame = newFrame
		}
	}

	// MARK: Element

	public override func applyDiff(other: Element<S>) {
		let otherLayout = other as Layout<S>
		if element.canDiff(otherLayout.element) {
			element.applyDiff(otherLayout.element)
		} else {
			let oldElement = element
			element = otherLayout.element
			curry(element.realize) <^> component <*> parentView
			if let parentView = parentView {
				curry(parentView.replaceSubview) <^> oldElement.getContentView() <*> element.getContentView()
			}
			oldElement.derealize()
		}

		super.applyDiff(other)

		layoutElements()
	}

	public override func realize(component: Component<S>, parentView: NSView) {
		self.component = component
		self.parentView = parentView
		
		element.realize(component, parentView: parentView)

		super.realize(component, parentView: parentView)
		
		layoutElements()
	}

	public override func derealize() {
		element.derealize()
	}

	public override func getContentView() -> NSView? {
		return element.getContentView()
	}
}
