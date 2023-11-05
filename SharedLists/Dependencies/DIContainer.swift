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
        register(AppStateStore.self) { _ in 
            AppStateStore(initial: AppState(),
                          reducer: appStateReducer,
                          middlewares: [
                          ])
        }
        .inObjectScope(.container)

        register(AuthorizationService.self) { resolver in
            let store = resolver.resolve(AppStateStore.self)!
            return FirebaseAuthorizationService(appStateStore: store) }
            .inObjectScope(.container)

//        register(EntriesProviderService.self) { resolver in
//            EntriesManager(storageService: resolver.resolve(StorageService.self)!)
//        }
//        .inObjectScope(.container)
    }
}
