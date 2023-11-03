//
//  SharedListsApp.swift
//  SharedLists
//
//  Created by Vadim Zhuk on 03/11/2023.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct SharedListsApp: App {

    let store = AppStateStore(
      initial: AppState(),
      reducer: appStateReducer,
      middlewares: [
      ])

    init() {
      store.dispatch(.launch)
    }

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
