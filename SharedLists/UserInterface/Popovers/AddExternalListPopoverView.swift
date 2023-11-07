//
//  AddExternalListPopoverView.swift
//  SharedLists
//
//  Created by Vadim Zhuk on 07/11/2023.
//

import SwiftUI

struct AddExternalListPopoverView: View {

    @EnvironmentObject var storage: FirestoreService

    @State var userId: String = ""
    @State var listId: String = ""

    @Binding var isPresented: Bool

    var body: some View {
        HStack {
            Spacer()
            TextField("User id", text: $userId)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.quaternary, lineWidth: 1)
                }

            TextField("External list id", text: $listId)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.quaternary, lineWidth: 1)
                }
            Spacer()
        }

            Button("Add", action: {
                Task {
                    await storage.addExternalList(with: listId, of: userId)
                }
                isPresented = false
            })
            .accessibilityIdentifier("Create")

            Button("Cancel", role: .cancel, action: {
                isPresented = false
            })
    }
}

#Preview {
    NewListPopoverView(isPresented: .constant(false))
}

extension View {
    public func addExternalListPopover(_ title: any StringProtocol,
                                     isPresented: Binding<Bool>) -> some View {
            return self.modifier(ExternalListAlert(title,
                                                isPresented: isPresented))
    }
}

struct ExternalListAlert: ViewModifier {
    let title: any StringProtocol
    var isPresented: Binding<Bool>

    init(_ title: any StringProtocol,
         isPresented: Binding<Bool>
    ) {
        self.title = title
        self.isPresented = isPresented
    }

    func body(content: Content) -> some View {
        ZStack(alignment: .center) {
            content
                .disabled(isPresented.wrappedValue)

            if isPresented.wrappedValue {
                VStack(spacing: 10) {
                    Text(title)

                    AddExternalListPopoverView(isPresented: isPresented)
                        .environmentObject(DIContainer.shared.resolve(FirestoreService.self)!)
                }
                .padding(.top, 20)
                .background(Color.white.opacity(0.1))
                .frame(width: 300, height: 175)
                .cornerRadius(20)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.quaternary, lineWidth: 1)
                }
            }
        }
    }
}
