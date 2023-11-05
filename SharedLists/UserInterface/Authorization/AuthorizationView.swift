//
//  AuthorizationView.swift
//  SharedLists
//
//  Created by Vadim Zhuk on 05/11/2023.
//

import SwiftUI

struct AuthorizationView: View {
    @State var havingAccount: Bool = false

    var body: some View {
        if havingAccount {
            LoginView(havingAccount: $havingAccount)
        } else {
            SignupView(havingAccount: $havingAccount)
        }
    }
}

#Preview {
    AuthorizationView()
}
