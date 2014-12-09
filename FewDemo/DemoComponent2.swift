//
//  DemoComponent2.swift
//  Few
//
//  Created by Josh Abernathy on 10/31/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import Few

struct DemoState2 {
	let loggedIn: Bool = false
	let logInState: LogInState
}

struct LogInState {
	let username: String = ""
	let password: String = ""
}

extension LogInState: Printable {
	var description: String { return "\(username), \(password)" }
}

class LogInComponent<S>: Few.Component<LogInState> {
	init(state: LogInState, loggedIn: (String, String) -> ()) {
		super.init(render: LogInComponent.render(loggedIn), initialState: state)
	}

	class func render(loggedIn: (String, String) -> ())(component: Few.Component<LogInState>, state: LogInState) -> Element {
		let usernameField = Input(initialText: "", placeholder: "Username") { str in
			component.updateState { LogInState(username: str, password: $0.password) }
		}

		let attributes = [
			NSForegroundColorAttributeName: NSColor.redColor(),
			NSFontAttributeName: NSFont.systemFontOfSize(11),
		]
		let enterUsername = Label(attributedString: NSAttributedString(string: "Enter a username", attributes: attributes))
		enterUsername.hidden = state.username.utf16Count > 0

		let passwordField = Input(initialText: "", placeholder: "Password") { str in
			component.updateState { LogInState(username: $0.username, password: str) }
		}

		let enterPassword = Label(attributedString: NSAttributedString(string: "Enter a password", attributes: attributes))
		enterPassword.hidden = state.password.utf16Count > 0

		let enabled = (state.username.utf16Count > 0 && state.password.utf16Count > 0)
		let loginButton = Button(title: "Login", enabled: enabled) {
			loggedIn(state.username, state.password)
		}

		let elements = [usernameField, enterUsername, passwordField, enterPassword, loginButton]
		return Container(elements |> leftAlign(16) |> verticalStack(component.frame.size.height, 4))
	}
}

class DemoComponent2<S>: Few.Component<DemoState2> {
	init() {
		let initialState = DemoState2(loggedIn: false, logInState: LogInState(username: "", password: ""))
		super.init(render: DemoComponent2.render, initialState: initialState)
	}

	class func render(component: Few.Component<DemoState2>, state: DemoState2) -> Element {
		if state.loggedIn {
			return DemoComponent1<DemoState1>() {
				component.updateState { DemoState2(loggedIn: false, logInState: $0.logInState) }
			}
		} else {
			return LogInComponent<LogInState>(state: state.logInState) { username, password in
				component.updateState { DemoState2(loggedIn: true, logInState: $0.logInState) }
			}
		}
	}
}
