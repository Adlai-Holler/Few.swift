//
//  ViewController.swift
//  FewDemo-iOS
//
//  Created by Coen Wessels on 13/03/15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import UIKit
import Few

func renderCounter(component: Component<Int>, count: Int) -> Element {
    let updateCounter = { component.updateState { $0 + 1 } }
    
    return Element()
        // The view itself should be centered.
        .justification(.Center)
        // The children should be centered in the view.
        .childAlignment(.Center)
        // Layout children in a column.
        .direction(.Column)
        .children([
            Label("You've clicked \(count) times!"),
            Button(title: "Click me!", action: updateCounter)
                .margin(Edges(uniform: 10))
                .width(100),
            ])
}

let Counter = { Component(initialState: 0, render: renderCounter) }

private func renderRow(row: Int) -> Element {
    return Element()
        .direction(.Row)
        .padding(Edges(uniform: 10))
        .children([
            Image(UIImage(named: "Apple_Swift_Logo.png"))
                .size(42, 42)
                .selfAlignment(.FlexStart),
            Element()
                .margin(Edges(left: 10))
                .direction(.Column)
                .children([
                    Label("I am a banana.", textColor: UIColor.blackColor(), font: UIFont.systemFontOfSize(18)),
                    Label("\(row)", textColor: UIColor.greenColor())
                    ])
            ])
}

struct TableViewState {
	let headerHeight: CGFloat
	let headerImage: UIImage
}

func renderTableView(component: Component<TableViewState>, state: TableViewState) -> Element {
	let header = Image(state.headerImage)
		.size(0, state.headerHeight)
		.selfAlignment(.FlexStart)
	let tv = TableView((1...100).map(renderRow),
		header: header,
		selectionChanged: println)
			.flex(1)
			.selfAlignment(.Stretch)
	return tv
}

let TableViewDemo: () -> Component<TableViewState> = {
	let component = Component(initialState: TableViewState(headerHeight: 42, headerImage: UIImage(named: "Apple_Swift_Logo.png")!), render: renderTableView)
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 2)), dispatch_get_main_queue()) {
		component.updateState { oldState in
			return TableViewState(headerHeight: oldState.headerHeight + 20, headerImage: oldState.headerImage)
		}
	}
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 5)), dispatch_get_main_queue()) {
		component.updateState { oldState in
			return TableViewState(headerHeight: oldState.headerHeight, headerImage: UIImage())
		}
	}
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 8)), dispatch_get_main_queue()) {
		component.updateState { oldState in
			return TableViewState(headerHeight: 0, headerImage: UIImage())
		}
	}
	return component
}

func renderInput(component: Component<String>, state: String) -> Element {
    return View(backgroundColor: UIColor.greenColor())
        .direction(.Column)
        .children([
            View(backgroundColor: UIColor.blueColor(), borderColor: UIColor.blackColor(), borderWidth: 2, cornerRadius: 5)
                .margin(Edges(uniform: 10))
                .size(100, 100),
            Input(placeholder: "Username")
                .margin(Edges(uniform: 10)),
            Input(placeholder: "Password", secure: true)
                .margin(Edges(uniform: 10))
            ])
}
let InputDemo = { Component(initialState: "", render: renderInput) }

struct AppState {
    let tableViewComponent: Component<TableViewState>
    let counterComponent: Component<Int>
    let inputComponent: Component<String>
    
    var activeComponent: ActiveComponent
    
    mutating func updateActiveComponent(newComponent: ActiveComponent) -> AppState {
        activeComponent = newComponent
        return self
    }
}
enum ActiveComponent {
    case TableView
    case Counter
    case Input
}

func renderApp(component: Few.Component<AppState>, state: AppState) -> Element {
    var contentComponent: Element!
    switch state.activeComponent {
    case .TableView:
        contentComponent = state.tableViewComponent
    case .Counter:
        contentComponent = state.counterComponent
    case .Input:
        contentComponent = state.inputComponent
    }
    
    let showMore = { component.updateState(toggleDisplay) }
    return Element()
        .direction(.Column)
        .children([
			Element()
				.children([
					contentComponent
				])
				.childAlignment(.Center)
				.justification(.Center)
				.flex(1),
            Button(title: "Show me more!", action: showMore)
                .width(200)
                .margin(Edges(uniform: 10))
                .selfAlignment(.Center)
		])
}

func toggleDisplay(var state: AppState) -> AppState {
    switch state.activeComponent {
    case .TableView:
        return state.updateActiveComponent(.Counter)
    case .Counter:
        return state.updateActiveComponent(.Input)
    case .Input:
        return state.updateActiveComponent(.TableView)
    }
}

