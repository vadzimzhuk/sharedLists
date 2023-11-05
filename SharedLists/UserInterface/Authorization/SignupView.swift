//
//  LoginView.swift
//  SharedLists
//
//  Created by Vadim Zhuk on 04/11/2023.
//

import SwiftUI

struct SignupView: View {
    @State var login: String = ""
    @State var password: String = ""
    
    @Binding var havingAccount: Bool

    var authorizationService: AuthorizationService = {
        DIContainer.shared.resolve(AuthorizationService.self)!
    }()

    var body: some View {
        VStack {
            Spacer()

            CredentialsView(buttonTitle: "Create account", login: $login, password: $password, buttonAction: authorizationService.signUp)
                .padding()

            VStack {
                Text("Alredy have an account?")
                Button {
                    havingAccount.toggle()
                } label: {
                    Text("Sign in")
                }
            }

            Spacer()
        }
    }
}

#Preview {
    SignupView(havingAccount: .constant(false))
}
