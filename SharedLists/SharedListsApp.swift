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
    private let storage: FirestoreService

    init() {
        DIContainer.shared.registerDependencies()
        store = DIContainer.shared.resolve(AppStateStore.self)!
        store.dispatch(.launch)

        FirebaseApp.configure()

        storage = DIContainer.shared.resolve(FirestoreService.self)!
        store.register(middleware: authorizeMiddleware(storage: storage))
    }

    @State var importListAlertShown: Bool = false
    @State var importListData: (userId: String, listId: String)? = nil

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .onOpenURL { url in
                    handle(url: url)
                }
                .alert("Import external list", isPresented: $importListAlertShown) {
                    Button("Import", role: .none) {
                        guard let importListData else { assertionFailure(); return }
                        
                        Task {
                            await storage.addExternalList(with: importListData.listId, of: importListData.userId)
                        }
                    }
                    Button("Cancel", role: .cancel, action: {})
                } message: {
                    Text("Do you really want to add shared list")
                }

        }
    }
}

extension SharedListsApp {
    enum RemoteAction: String {
        case sharelist
        case unhandled
    }

    private func handle(url: URL) {
        let actionData = parseData(from: url)
        // check if the user isnt the current one
        importListData = (actionData.userId, actionData.listId)

        guard actionData.userId != store.state.currentUser?.id else { return } // TODO: - open own list
        
        importListAlertShown = true
    }

    private func parseData(from url: URL) -> (command: RemoteAction, userId: String, listId: String) {
        let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false)
        let query = components?.queryItems

        let listId = query?.first { $0.name == "listid" }?.value ?? ""
        let userId = query?.first { $0.name == "userid" }?.value ?? ""

        let command = RemoteAction(rawValue: String(url.host()?.split(separator: ".").first ?? "")) ?? .unhandled

        return (command: command, userId: userId, listId: listId)
    }
}
