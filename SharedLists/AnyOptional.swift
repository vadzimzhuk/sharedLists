//
//  AnyOptional.swift
//  Patterson
//
//  Created by Vadim Zhuk on 18.03.22.
//

import Foundation

public protocol AnyOptional {
    /// Returns `true` if `nil`, otherwise `false`.
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    
    public var isNil: Bool { self == nil }

    public var isNotNil: Bool { !isNil }

    func or(_ value: @autoclosure () -> Wrapped) -> Wrapped {
        return self ?? value()
    }
}
