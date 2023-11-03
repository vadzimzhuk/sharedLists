//
//  ContentView.swift
//  SharedLists
//
//  Created by Vadim Zhuk on 03/11/2023.
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject var store: AppStateStore

    var body: some View {
        if store.state.isAuthorized {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
            }
            .padding()
        } else {
            VStack {
                Image(systemName: "person")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Please, log in.")
            }
            .padding()
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
