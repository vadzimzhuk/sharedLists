//
//  DIContainer.swift
//  SharedLists
//
//  Created by Vadim Zhuk on 04/11/2023.
//

import Foundation
import Swinject

protocol DIContainerProtocol {
    func register<Component>(_ type: Component.Type, factory: @escaping (Resolver) -> Component) -> ServiceEntry<Component>
    func resolve<Component>(_ type: Component.Type) -> Component?
}

final class DIContainer: DIContainerProtocol {

    static let shared = DIContainer()

    init() {
        registerDependencies()
    }

    let container: Container = Container()

    var components: [String: Any] = [:]

    @discardableResult
    func register<Component>(_ type: Component.Type, factory: @escaping (Resolver) -> Component) -> ServiceEntry<Component> {
        container.register(type, factory: factory)
    }

    func resolve<Component>(_ type: Component.Type) -> Component? {
        container.resolve(type)
    }
}

extension DIContainer {

    func registerDependencies() {

        register(AppStateStore.self) { resolver in
            AppStateStore(initial: AppState(),
                          reducer: appStateReducer,
                          middlewares: [
                          ])
        }
        .inObjectScope(.container)

        register(FirestoreService.self) { resolver in
            let appStateStore = resolver.resolve(AppStateStore.self)!
            return FirestoreService(appStateStore: appStateStore)
        }
        .inObjectScope(.container)


        register(AuthorizationService.self) { resolver in
            let store = resolver.resolve(AppStateStore.self)!
            return FirebaseAuthorizationService(appStateStore: store) }
            .inObjectScope(.container)
    }
}
