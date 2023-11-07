//
//  NewListPopoverView.swift
//  SharedLists
//
//  Created by Vadim Zhuk on 05/11/2023.
//

import SwiftUI

struct NewListPopoverView: View {

    @EnvironmentObject var storage: FirestoreService

    @State var listTitle: String = ""

    @Binding var isPresented: Bool

    var body: some View {
        HStack {
            Spacer()
            TextField("New list name", text: $listTitle)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.quaternary, lineWidth: 1)
                }
            Spacer()
        }

            Button("Create", action: {
                let list = ListEntry(id: "", title: listTitle, text: "", items: [])
                storage.create(list: list)
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
    public func createNewListPopover(_ title: any StringProtocol,
                                     isPresented: Binding<Bool>) -> some View {
            return self.modifier(NewListAlert(title,
                                                isPresented: isPresented))
    }
}

struct NewListAlert: ViewModifier {
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

                    NewListPopoverView(isPresented: isPresented)
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
