//
//  Middleware.swift
//  SharedLists
//
//  Created by Vadim Zhuk on 03/11/2023.
//

import Foundation
import Combine

typealias Middleware<State, Action> = (State, Action) -> AnyPublisher<Action, Never>
typealias AppMiddleware = Middleware<AppState, AppAction>

func authorizeMiddleware(storage: FirestoreService, authorizationService: AuthorizationService) -> AppMiddleware {
    { state, action in
        switch action {
            case .authorize(let user):
                storage.subscribeOnDataUpdates(user: user.id)
            default:
                break
        }

        return Empty().eraseToAnyPublisher()
    }
}
