//
//  WrapperView.swift
//  SharedLists
//
//  Created by Vadim Zhuk on 06/11/2023.
//

import Foundation
import SwiftUI

struct WrapperView <Content: View>: View {

    var content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) { self.content = content }

    var body: some View {

            content()

    }
}
