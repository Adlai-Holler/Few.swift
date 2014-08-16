//
//  Graphic.swift
//  Few
//
//  Created by Josh Abernathy on 8/6/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

private class DrawableView: NSView {
	private let draw: CGRect -> ()

	init(frame: NSRect, draw: CGRect -> ()) {
		self.draw = draw
		super.init(frame: frame)
	}

	required init(coder: NSCoder) {
		fatalError("DrawableView shouldn't be serialized.");
	}

	override func drawRect(rect: NSRect) {
		draw(rect)
	}
}

public func rect<S>(color: NSColor) -> Graphic<S> {
	return Graphic { rect in
		color.set()
		NSRectFillUsingOperation(rect, .CompositeSourceOver)
	}
}

public class Graphic<S: Equatable>: Element<S> {
	private var view: DrawableView?

	private var draw: CGRect -> ()

	public init(draw: CGRect -> ()) {
		self.draw = draw
	}

	// MARK: Element

	public override func applyDiff(other: Element<S>) {
		let otherGraphic = other as Graphic
		draw = otherGraphic.draw
		view?.needsDisplay = true
	}

	public override func realize(component: Component<S>, parentView: NSView) {
		view = DrawableView(frame: frame, draw: callDrawFunc)

		super.realize(component, parentView: parentView)
	}

	private func callDrawFunc(rect: CGRect) {
		draw(rect)
	}

	public override func getContentView() -> NSView? {
		return view
	}
}
