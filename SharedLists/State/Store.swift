//
//  Store.swift
//  SharedLists
//
//  Created by Vadim Zhuk on 03/11/2023.
//

import Foundation
import Combine

typealias AppStateStore = Store<AppState, AppAction>

class Store<State, Action>: ObservableObject {

    @Published private(set) var state: State

    private let reducer: Reducer<State, Action>
    private var middlewares: [Middleware<State, Action>]

    private let queue = DispatchQueue(label: "one.zhuk.sharedlists.store", qos: .userInitiated)
    private var subscriptions: Set<AnyCancellable> = []

    init(
        initial: State,
        reducer: @escaping Reducer<State, Action>,
        middlewares: [Middleware<State, Action>] = []
    ) {
        self.state = initial
        self.reducer = reducer
        self.middlewares = middlewares
    }

        // The dispatch function dispatches an action to the serial queue.
    func dispatch(_ action: Action) {
        queue.sync {
            self.dispatch(self.state, action)
        }
    }

        // The internal work for dispatching actions
    private func dispatch(_ currentState: State, _ action: Action) {
            // generate a new state using the reducer
        let newState = reducer(currentState, action)

            // pass the new state and action to all the middlewares
            // if they publish an action dispatch pass it to the dispatch function
        middlewares.forEach { middleware in
            let publisher = middleware(newState, action)
            publisher
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: dispatch)
                .store(in: &subscriptions)
        }

            // Finally set the state to the new state
        DispatchQueue.main.async { [weak self] in
            self?.state = newState
        }
    }

    func register(middleware: @escaping Middleware<State, Action>) {
        middlewares.append(middleware)
    }
}

extension AppStateStore {
  static var preview: AppStateStore {
    AppStateStore(
      initial: AppState(),
      reducer: appStateReducer,
      middlewares: [
        // TODO: - add middlewares if needed
      ])
  }
}
