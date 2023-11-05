//
//  AuthorizationService.swift
//  SharedLists
//
//  Created by Vadim Zhuk on 03/11/2023.
//

import Foundation
import FirebaseAuth

protocol AuthorizationService {
    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String) async throws
    func signOut() async throws
}

enum AppError: Error {
    case unexpectedBehaviour(class: AnyClass)
}

actor FirebaseAuthorizationService: AuthorizationService {
    static let unexpectedBehaviourError: Error = AppError.unexpectedBehaviour(class: FirebaseAuthorizationService.self)
    let appStateStore: AppStateStore
    
    private var authStateListener: AuthStateDidChangeListenerHandle

    init(appStateStore: AppStateStore) {
        self.appStateStore = appStateStore
        authStateListener = Auth.auth().addStateDidChangeListener { auth, user in
            if let firebaseUser = auth.currentUser {
                let user = User(id: firebaseUser.uid)
                appStateStore.dispatch(.authorize(user))
            } else {
                appStateStore.dispatch(.logout)
            }
        }
    }

    func signOut() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) -> Void in
            do {
                try Auth.auth().signOut()
                appStateStore.dispatch(.logout)
                continuation.resume()
            } catch {
                continuation.resume(throwing: error)
            }

        }
    }

    func signIn(email: String, password: String) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) -> Void in
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let self else {
                    continuation.resume(throwing: Self.unexpectedBehaviourError)
                    return
                }

                if let firebaseUser = authResult?.user {
                    let user = User(id: firebaseUser.uid)
                    appStateStore.dispatch(.authorize(user))
                }

                continuation.resume()
            }
        }
    }
    
    func signUp(email: String, password: String) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let self else { 
                    continuation.resume(throwing: Self.unexpectedBehaviourError)
                    return
                }

                if let firebaseUser = authResult?.user {
                    let user = User(id: firebaseUser.uid)
                    appStateStore.dispatch(.authorize(user))
                }

                continuation.resume()
            }
        }
    }
}
