//
//  LoginPasswordView.swift
//  SharedLists
//
//  Created by Vadim Zhuk on 04/11/2023.
//

import SwiftUI

struct CredentialsView: View {
    let buttonTitle: String

    @Binding var login: String
    @Binding var password: String

    @State var isLoading: Bool = false

    let buttonAction: (String, String) async throws -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Email:")
            TextField("Email", text: $login)
                .keyboardType(.emailAddress)
                .border(.gray, width: 1)

            Spacer()
                .frame(height: 10)

            Text("Password:")
            SecureField("Password", text: $password)
                .border(.gray, width: 1)

            Spacer()
                .frame(height: 10)

            HStack {
                Spacer()
                Button(action: {
                    Task {
                        isLoading = true
                        do {
                            try await buttonAction(login, password)
                        } catch {
                            print(error)
                        }
                        isLoading = false

                    }
                }, label: {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text(buttonTitle)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white, lineWidth: 2))
                    }
                })
                .background {
                    Color.cyan
                }
                .cornerRadius(25)

                Spacer()
            }
        }
    }
}

#Preview {
    CredentialsView(buttonTitle: "Sign in", login: .constant(""), password: .constant(""), isLoading: false, buttonAction: {_,_ in})
        .padding()
}
