//
//  CastOrFail.swift
//  EasyHue
//
//  Created by Jochen Pfeiffer on 19/12/2016.
//  Copyright © 2016 Jochen Pfeiffer. All rights reserved.
//

import Foundation

/// RxCocoa errors.
public enum PSError
    : Swift.Error
    , CustomDebugStringConvertible {
    /// Unknown error has occurred.
    case unknown
    /// Invalid operation was attempted.
    case invalidOperation(object: Any)
    /// Casting error.
    case castingError(object: Any, targetType: Any.Type)
}

// MARK: Debug descriptions

extension PSError {
    /// A textual representation of `self`, suitable for debugging.
    public var debugDescription: String {
        switch self {
        case .unknown:
            return "Unknown error occurred."
        case let .invalidOperation(object):
            return "Invalid operation was attempted on `\(object)`."
        case .castingError(let object, let targetType):
            return "Error casting `\(object)` to `\(targetType)`"
        }
    }
}

// MARK: casts or fatal error

// workaround for Swift compiler bug
func castOptionalOrFatalError<T>(_ value: Any?) -> T? {
    if value == nil {
        return nil
    }
    let v: T = castOrFatalError(value)
    return v
}

func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw PSError.castingError(object: object, targetType: resultType)
    }

    return returnValue
}

func castOptionalOrThrow<T>(_ resultType: T.Type, _ object: AnyObject) throws -> T? {
    if NSNull().isEqual(object) {
        return nil
    }

    guard let returnValue = object as? T else {
        throw PSError.castingError(object: object, targetType: resultType)
    }

    return returnValue
}

func castOrFatalError<T>(_ value: AnyObject!, message: String) -> T {
    let maybeResult: T? = value as? T
    guard let result = maybeResult else {
        psFatalError(message)
    }

    return result
}

func castOrFatalError<T>(_ value: Any!) -> T {
    let maybeResult: T? = value as? T
    guard let result = maybeResult else {
        psFatalError("Failure converting from \(value) to \(T.self)")
    }

    return result
}

func psFatalError(_ lastMessage: String) -> Never {
    fatalError(lastMessage)
}
