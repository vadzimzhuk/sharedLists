//
//  Reducer.swift
//  SharedLists
//
//  Created by Vadim Zhuk on 03/11/2023.
//

import Foundation

typealias Reducer<State, Action> = (State, Action) -> State

let appStateReducer: Reducer<AppState, AppAction> = { state, action in
    var mutatingState = state

    switch action {
        case .launch:
            break
        case .authorize:
            // TODO: - implement
            break
    }

    return mutatingState
}
