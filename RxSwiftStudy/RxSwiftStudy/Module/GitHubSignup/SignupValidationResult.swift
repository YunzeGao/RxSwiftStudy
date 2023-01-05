//
//  SignupValidationResult.swift
//  RxSwiftStudy
//
//  Created by 高云泽 on 2023/1/5.
//

import UIKit

enum SignupValidationResult {
    case ok(message: String)
    case empty
    case validating
    case failed(message: String)
}

extension SignupValidationResult: CustomStringConvertible {
    var description: String {
        switch self {
        case let .ok(message):
            return message
        case .empty:
            return ""
        case .validating:
            return "validating ..."
        case let .failed(message):
            return message
        }
    }
}

struct SignupValidationColors {
    static let okColor = UIColor(red: 138.0 / 255.0, green: 221.0 / 255.0, blue: 109.0 / 255.0, alpha: 1.0)
    static let errorColor = UIColor.red
}

extension SignupValidationResult {
    var textColor: UIColor {
        switch self {
        case .ok:
            return SignupValidationColors.okColor
        case .empty:
            return UIColor.black
        case .validating:
            return UIColor.black
        case .failed:
            return SignupValidationColors.errorColor
        }
    }
}

extension SignupValidationResult {
    var isValid: Bool {
        switch self {
        case .ok:
            return true
        default:
            return false
        }
    }
}
