//
//  ContentView.swift
//  SharedLists
//
//  Created by Vadim Zhuk on 03/11/2023.
//

import SwiftUI

struct ContentView: View {
    @State var storage: FirestoreService = DIContainer.shared.resolve(FirestoreService.self)!

    @EnvironmentObject var store: AppStateStore

    var authorizationService: AuthorizationService = {
        DIContainer.shared.resolve(AuthorizationService.self)!
    }()

    var body: some View {
        if let _ = store.state.currentUser {
            NavigationStack {
                VStack {

                    ListEntriesView(listEntries: $storage.listEntries)
                        .environmentObject(storage)

                    Button(action: {
                        Task {
                            try? await authorizationService.signOut()
                        }
                    }, label: {
                        Text("Sign out")
                    })
                }
                .padding()
                .navigationTitle("SharedLists")
            }
            .navigationBarTitleDisplayMode(.large)
        } else {
            AuthorizationView()
        }

    }
}

#Preview {

    ContentView()
        .environmentObject(AppStateStore(
            initial: AppState(),
            reducer: appStateReducer,
            middlewares: []))
}
