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
    
    return View()
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
    return View()
        .direction(.Row)
        .padding(Edges(uniform: 10))
        .children([
            Image(UIImage(named: "Apple_Swift_Logo.png"))
                .size(42, 42)
                .selfAlignment(.FlexStart),
            Label("I am a banana.", textColor: UIColor.yellowColor(), font: UIFont.systemFontOfSize(18)),
            Label("\(row)")
            ])
}

func renderTableView(component: Component<()>, state: ()) -> Element {
    return TableView((1...100).map(renderRow), selectionChanged: println)
}

let TableViewDemo = { Component(initialState: (), render: renderTableView) }

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
    let tableViewComponent: Component<()>
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
            contentComponent
                .margin(Edges(top: 20))
                .flex(1),
            Button(title: "Show me more!", action: showMore)
                .selfAlignment(.Stretch)
                .margin(Edges(uniform: 10))
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

class ViewController: UIViewController {
    private let appComponent = Component(
        initialState: AppState(
            tableViewComponent: TableViewDemo(),
            counterComponent: Counter(),
            inputComponent: InputDemo(),
            activeComponent: .TableView
        ),
        render: renderApp
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appComponent.addToView(view)
    }
}

