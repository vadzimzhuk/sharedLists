//
//  SharedListsApp.swift
//  SharedLists
//
//  Created by Vadim Zhuk on 03/11/2023.
//

import SwiftUI
import FirebaseCore

@main
struct SharedListsApp: App {

    private let store: AppStateStore

    init() {
        DIContainer.shared.registerDependencies()
        store = DIContainer.shared.resolve(AppStateStore.self)!
        store.dispatch(.launch)

        FirebaseApp.configure()

        let storage: FirestoreService = DIContainer.shared.resolve(FirestoreService.self)!
        store.register(middleware: authorizeMiddleware(storage: storage))
    }


    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
