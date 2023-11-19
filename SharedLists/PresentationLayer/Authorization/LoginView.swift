//
//  LoginView.swift
//  SharedLists
//
//  Created by Vadim Zhuk on 04/11/2023.
//

import SwiftUI

struct LoginView: View {
    @State var login: String = ""
    @State var password: String = ""

    @Binding var havingAccount: Bool

    var authorizationService: AuthorizationService = {
        DIContainer.shared.resolve(AuthorizationService.self)!
    }()

    var body: some View {
        VStack {
            Spacer()

            CredentialsView(buttonTitle: "Sign in", login: $login, password: $password, buttonAction: authorizationService.signIn)
                .padding()
            
            VStack {
                Text("Don't have an account?")
                Button {
                    havingAccount.toggle()
                } label: {
                    Text("Create account")
                }
            }

            Spacer()
        }
    }
}

#Preview {
    LoginView(havingAccount: .constant(false))
}
