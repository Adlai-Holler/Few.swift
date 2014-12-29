//
//  Layout.swift
//  Few
//
//  Created by Josh Abernathy on 12/3/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import CoreGraphics

extension Array {
	func mapWithState<S>(initial: S, fn: (S, T) -> (S, T)) -> [T] {
		var newArray: [T] = []
		var currentState = initial
		for element in self {
			let (newState, newElement) = fn(currentState, element)
			newArray.append(newElement)
			currentState = newState
		}

		return newArray
	}
}

public func leftAlign(x: CGFloat)(elements: [Element]) -> [Element] {
	return elements.map { el in el.x(x) }
}

public func verticalStack(top: CGFloat, padding: CGFloat)(elements: [Element]) -> [Element] {
	return elements
		.filter { !$0.hidden }
		.mapWithState(top) { currentY, el in
			let y = currentY - (el.frame.size.height + padding)
			let newElement = el.y(y)
			return (y, newElement)
		}
}

public func horizontalStack(left: CGFloat, padding: CGFloat)(elements: [Element]) -> [Element] {
	return elements
		.filter { !$0.hidden }
		.mapWithState(left) { currentX, el in
			let x = currentX + el.frame.size.width + padding
			let newElement = el.x(x)
			return (x, newElement)
		}
}

public func offset(x: CGFloat, y: CGFloat)(elements: [Element]) -> [Element] {
	return elements.map { el in el.frame(CGRectOffset(el.frame, x, y)) }
}

extension Element {
	final public func above(other: Element) -> Self {
		return y(other.frame.origin.y + other.frame.size.height)
	}

	final public func below(other: Element) -> Self {
		return y(other.frame.origin.y - frame.size.height)
	}

	final public func left(other: Element) -> Self {
		return x(other.frame.origin.x - frame.size.width)
	}

	final public func right(other: Element) -> Self {
		return x(other.frame.origin.x + other.frame.size.width)
	}

	final public func alignTop(other: Element) -> Self {
		return y(other.frame.origin.y + other.frame.size.height - frame.size.height)
	}

	final public func alignBottom(other: Element) -> Self {
		return y(other.frame.origin.y)
	}

	final public func alignLeft(other: Element) -> Self {
		return x(other.frame.origin.x)
	}

	final public func alignRight(other: Element) -> Self {
		return x(other.frame.origin.x + other.frame.size.width - frame.size.width)
	}

	final public func centerY(other: Element) -> Self {
		return y(other.frame.origin.y + ceil(other.frame.size.height/2 - frame.size.height/2))
	}

	final public func centerX(other: Element) -> Self {
		return x(other.frame.origin.x + ceil(other.frame.size.width/2 - frame.size.width/2))
	}

	final public func center(other: Element) -> Self {
		return centerX(other).centerY(other)
	}

	final public func offsetX(dx: CGFloat) -> Self {
		return x(frame.origin.x + dx)
	}

	final public func offsetY(dy: CGFloat) -> Self {
		return y(frame.origin.y + dy)
	}
}
