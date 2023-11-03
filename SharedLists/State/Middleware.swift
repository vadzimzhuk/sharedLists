//
//  Middleware.swift
//  SharedLists
//
//  Created by Vadim Zhuk on 03/11/2023.
//

import Foundation
import Combine

typealias Middleware<State, Action> = (State, Action) -> AnyPublisher<Action, Never>
