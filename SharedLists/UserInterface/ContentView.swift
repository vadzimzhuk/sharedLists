//
//  ContentView.swift
//  SharedLists
//
//  Created by Vadim Zhuk on 03/11/2023.
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject var store: AppStateStore
    
    var authorizationService: AuthorizationService = {
        DIContainer.shared.resolve(AuthorizationService.self)!
    }()

    var body: some View {
        if let _ = store.state.currentUser {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")

                Button(action: {
                    Task {
                        try? await authorizationService.signOut()
                    }
                }, label: {
                    Text("Sign out")
                })
            }
            .padding()
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
